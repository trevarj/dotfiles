(define-module (trev-guix services networking)
  #:use-module (gnu services)
  #:use-module (gnu services dbus)
  #:use-module (gnu services linux)
  #:use-module (gnu services shepherd)
  #:use-module ((gnu packages linux) #:select (iproute))
  #:use-module (trev-guix packages networking)
  #:use-module (trev-guix services utils)
  #:use-module (guix gexp)
  #:use-module (guix records))

(define-public byedpi-service-type
  (simple-daemon-service-type 'byedpi "ciadpi"))

(define-public gost-service-type
  (simple-daemon-service-type 'gost "gost"))

(define-record-type* <nym-vpn-configuration>
  nym-vpn-configuration make-nym-vpn-configuration
  nym-vpn-configuration?
  (nym-vpn nym-vpn-configuration-nym-vpn
           (default nym-vpn)))

(define %nym-vpn-polkit-policy
  (file-union
   "nym-vpn-polkit-policy"
   `(("share/polkit-1/actions/com.nymvpn.vpnd.unix-access.policy"
      ,(local-file "../files/com.nymvpn.vpnd.unix-access.policy")))))

(define (nym-vpn-shepherd-service config)
  (match-record config <nym-vpn-configuration> (nym-vpn)
    (list
     (shepherd-service
      (documentation "Run the Nym VPN daemon.")
      (provision '(nym-vpnd))
      (requirement '(user-processes dbus-system loopback networking
                     kernel-module-loader))
      (start #~(make-forkexec-constructor
                (list #$(file-append nym-vpn "/bin/nym-vpnd"))
                #:environment-variables
                (list (string-append
                       "PATH=" #$(file-append iproute "/sbin")))
                #:log-file "/var/log/nym-vpnd.log"))
      (stop #~(make-kill-destructor))))))

(define-public nym-vpn-service-type
  (service-type
   (name 'nym-vpn)
   (extensions
    (list (service-extension shepherd-root-service-type
                             nym-vpn-shepherd-service)
          (service-extension polkit-service-type
                             (lambda _
                               (list %nym-vpn-polkit-policy)))
          (service-extension kernel-module-loader-service-type
                             (lambda _
                               '("tun")))
          (service-extension profile-service-type
                             (compose list nym-vpn-configuration-nym-vpn))))
   (default-value (nym-vpn-configuration))
   (description "Run the Nym VPN daemon and install its polkit action.")))

(define-public nym-service-type nym-vpn-service-type)
