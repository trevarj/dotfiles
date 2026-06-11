;;; forge-export.el --- Export Magit Forge topics  -*- lexical-binding: t; -*-

;; Run with:
;; emacs -Q --batch -l forge-export.el -- --repo auto --type pullreq --number 1

(require 'cl-lib)
(require 'json)
(require 'subr-x)

(defvar forge-export--args
  (cdr (member "--" command-line-args)))

(defun forge-export--arg (name &optional default required)
  (let ((tail (member name forge-export--args)))
    (cond
     ((and tail (cadr tail))
      (setq forge-export--args (delete (cadr tail) (delete (car tail) forge-export--args)))
      (cadr tail))
     (tail
      (error "Missing value for %s" name))
     (required
      (error "Missing required argument %s" name))
     (t default))))

(defun forge-export--flag-p (name)
  (when (member name forge-export--args)
    (setq forge-export--args (delete name forge-export--args))
    t))

(defun forge-export--parse-args ()
  (let ((opts `((repo . ,(forge-export--arg "--repo" "auto"))
                (type . ,(forge-export--arg "--type" "pullreq"))
                (number . ,(forge-export--arg "--number" "0"))
                (format . ,(forge-export--arg "--format" "both"))
                (out-dir . ,(forge-export--arg "--out-dir" (make-temp-file "forge-export-" t)))
                (refresh . t)
                (review-threads . nil)
                (self-test . nil))))
    (when (forge-export--flag-p "--no-refresh")
      (setcdr (assq 'refresh opts) nil))
    (when (forge-export--flag-p "--refresh")
      (setcdr (assq 'refresh opts) t))
    (when (forge-export--flag-p "--include-review-threads")
      (setcdr (assq 'review-threads opts) t))
    (when (forge-export--flag-p "--self-test")
      (setcdr (assq 'self-test opts) t))
    (unless (zerop (length forge-export--args))
      (error "Unknown arguments: %S" forge-export--args))
    opts))

(defun forge-export--opt (opts key)
  (cdr (assq key opts)))

(defun forge-export--setup-packages ()
  (require 'package)
  (setq package-user-dir (expand-file-name "elpa" user-emacs-directory))
  (package-initialize)
  (require 'forge)
  (require 'forge-client)
  (require 'forge-commands)
  (require 'forge-github)
  (require 'ghub-graphql)
  (require 'ghub-legacy)
  (require 'json))

(defun forge-export--resolve-repo (repo-spec insertp)
  (cond
   ((equal repo-spec "auto")
    (forge-get-repository :stub))
   ((string-match "\\`\\([^/]+\\)/\\([^/]+\\)\\'" repo-spec)
    (forge-get-repository
     (list "github.com" (match-string 1 repo-spec) (match-string 2 repo-spec))
     nil (if insertp :insert! :known?)))
   ((string-match "\\`\\([^/]+\\)/\\([^/]+\\)/\\([^/]+\\)\\'" repo-spec)
    (forge-get-repository
     (list (match-string 1 repo-spec) (match-string 2 repo-spec) (match-string 3 repo-spec))
     nil (if insertp :insert! :known?)))
   (t
    (forge-get-repository repo-spec nil (if insertp :insert! :known?)))))

(defun forge-export--query-topic (repo type number)
  (let* ((narrow (pcase type
                   ("issue" `(repository issues (issue . ,number)))
                   ("pullreq" `(repository pullRequests (pullRequest . ,number)))
                   (_ (error "Unsupported type: %s" type))))
         (data (ghub-query
                (ghub--graphql-narrow-query forge--github-repository-query narrow)
                `((owner . ,(oref repo owner))
                  (name . ,(oref repo name)))
                :auth 'forge
                :host (oref repo apihost)
                :forge 'github
                :narrow (pcase type
                          ("issue" '(repository issue))
                          ("pullreq" '(repository pullRequest)))
                :paginate t
                :synchronous t)))
    (pcase type
      ("issue" (forge--update-issue repo data))
      ("pullreq" (forge--update-pullreq repo data)))))

(defun forge-export--cached-topic (repo type number)
  (pcase type
    ("issue" (forge-get-issue repo number))
    ("pullreq" (forge-get-pullreq repo number))
    (_ (error "Unsupported type: %s" type))))

(defun forge-export--review-threads (repo number)
  (unless (forge-github-repository-p repo)
    (error "Review threads are only implemented for GitHub repositories"))
  (let ((data (ghub-query
               (ghub--graphql-narrow-query
                ghub-fetch-repository-review-threads
                `(repository pullRequests (pullRequest . ,number)))
               `((owner . ,(oref repo owner))
                 (name . ,(oref repo name)))
               :auth 'forge
               :host (oref repo apihost)
               :forge 'github
               :narrow '(repository pullRequest)
               :paginate t
               :synchronous t)))
    (let-alist data
      (mapcar #'forge-export--review-thread-alist .reviewThreads))))

(defun forge-export--latest-number (repo type)
  (let* ((field (pcase type
                  ("issue" 'issues)
                  ("pullreq" 'pullRequests)
                  (_ (error "Unsupported type: %s" type))))
         (data (ghub-query
                `(query
                  [($owner String!)
                   ($name String!)]
                  (repository
                   [(owner $owner)
                    (name $name)]
                   (,field
                    [(:edges 1)
                     (orderBy ((field CREATED_AT) (direction DESC)))]
                    number)))
                `((owner . ,(oref repo owner))
                  (name . ,(oref repo name)))
                :auth 'forge
                :host (oref repo apihost)
                :forge 'github
                :narrow `(repository ,field)
                :synchronous t)))
    (or (alist-get 'number (car data))
        (error "No %s found for %s/%s" type (oref repo owner) (oref repo name)))))

(defun forge-export--topic-extra (repo type number)
  (let* ((field (pcase type
                  ("issue" 'issue)
                  ("pullreq" 'pullRequest)
                  (_ (error "Unsupported type: %s" type))))
         (data (ghub-query
                `(query
                  [($owner String!)
                   ($name String!)]
                  (repository
                   [(owner $owner)
                    (name $name)]
                   (,field
                    [(number ,number)]
                    (labels [(:edges t)] name color description)
                    (assignees [(:edges t)] login))))
                `((owner . ,(oref repo owner))
                  (name . ,(oref repo name)))
                :auth 'forge
                :host (oref repo apihost)
                :forge 'github
                :narrow `(repository ,field)
                :paginate t
                :synchronous t)))
    data))

(defun forge-export--string (value)
  (cond
   ((null value) nil)
   ((symbolp value) (symbol-name value))
   (t value)))

(defun forge-export--vector (items)
  (vconcat (or items nil)))

(defun forge-export--empty-p (items)
  (or (null items)
      (and (vectorp items) (= (length items) 0))))

(defun forge-export--related (obj slot)
  (or (ignore-errors (closql-dref obj slot))
      (ignore-errors (oref obj slot))
      nil))

(defun forge-export--people (people)
  (forge-export--vector
   (mapcar (lambda (person) (oref person login)) people)))

(defun forge-export--labels (labels)
  (forge-export--vector
   (mapcar
    (lambda (label)
      `((name . ,(oref label name))
        (color . ,(oref label color))
        (description . ,(oref label description))))
    labels)))

(defun forge-export--extra-labels (extra)
  (forge-export--vector
   (mapcar
    (lambda (label)
      `((name . ,(alist-get 'name label))
        (color . ,(alist-get 'color label))
        (description . ,(alist-get 'description label))))
    (alist-get 'labels extra))))

(defun forge-export--extra-people (extra)
  (forge-export--vector
   (mapcar
    (lambda (person) (alist-get 'login person))
    (alist-get 'assignees extra))))

(defun forge-export--post-alist (post)
  `((id . ,(oref post id))
    (number . ,(oref post number))
    (author . ,(oref post author))
    (created . ,(oref post created))
    (updated . ,(oref post updated))
    (body . ,(oref post body))))

(defun forge-export--topic-url (repo topic type)
  (or (ignore-errors (forge-get-url topic))
      (format "https://%s/%s/%s/%s/%s"
              (oref repo forge)
              (oref repo owner)
              (oref repo name)
              (if (equal type "pullreq") "pull" "issues")
              (oref topic number))))

(defun forge-export--topic-alist (repo topic type review-threads extra)
  (let ((base `((provider . "github")
                (repo . ,(format "%s/%s" (oref repo owner) (oref repo name)))
                (host . ,(oref repo forge))
                (type . ,type)
                (number . ,(oref topic number))
                (url . ,(forge-export--topic-url repo topic type))
                (state . ,(forge-export--string (oref topic state)))
                (title . ,(oref topic title))
                (author . ,(oref topic author))
                (created . ,(oref topic created))
                (updated . ,(oref topic updated))
                (closed . ,(oref topic closed))
                (locked . ,(oref topic locked-p))
                (labels . ,(if extra
                                (forge-export--extra-labels extra)
                              (forge-export--labels (forge-export--related topic 'labels))))
                (assignees . ,(if extra
                                  (forge-export--extra-people extra)
                                (forge-export--people (forge-export--related topic 'assignees))))
                (body . ,(oref topic body))
                (comments . ,(forge-export--vector
                               (mapcar #'forge-export--post-alist
                                       (forge-export--related topic 'posts)))))))
    (when (forge-pullreq-p topic)
      (setq base
            (append base
                    `((merged . ,(oref topic merged))
                      (draft . ,(oref topic draft-p))
                      (base_ref . ,(oref topic base-ref))
                      (base_repo . ,(oref topic base-repo))
                      (base_rev . ,(oref topic base-rev))
                      (head_ref . ,(oref topic head-ref))
                      (head_user . ,(oref topic head-user))
                      (head_repo . ,(oref topic head-repo))
                      (head_rev . ,(oref topic head-rev))
                      (review_threads . ,(forge-export--vector review-threads))))))
    base))

(defun forge-export--review-thread-alist (thread)
  `((id . ,(alist-get 'id thread))
    (line . ,(alist-get 'line thread))
    (original_line . ,(alist-get 'originalLine thread))
    (diff_side . ,(alist-get 'diffSide thread))
    (resolved_by . ,(alist-get 'login (alist-get 'resolvedBy thread)))
    (comments . ,(forge-export--vector
                  (mapcar #'forge-export--review-comment-alist
                          (alist-get 'comments thread))))))

(defun forge-export--review-comment-alist (comment)
  `((id . ,(alist-get 'id comment))
    (database_id . ,(alist-get 'databaseId comment))
    (author . ,(alist-get 'login (alist-get 'author comment)))
    (created . ,(alist-get 'createdAt comment))
    (updated . ,(alist-get 'updatedAt comment))
    (body . ,(alist-get 'body comment))
    (reply_to . ,(alist-get 'databaseId (alist-get 'replyTo comment)))
    (commit . ,(alist-get 'oid (alist-get 'originalCommit comment)))
    (path . ,(alist-get 'path comment))))

(defun forge-export--md-line (label value)
  (when value
    (format "- %s: %s\n" label value)))

(defun forge-export--markdown (topic)
  (let-alist topic
    (concat
     (format "# %s #%s: %s\n\n" .type .number .title)
     (mapconcat #'identity
                (delq nil
                      (list
                       (forge-export--md-line "Repository" .repo)
                       (forge-export--md-line "URL" .url)
                       (forge-export--md-line "State" .state)
                       (forge-export--md-line "Author" .author)
                       (forge-export--md-line "Created" .created)
                       (forge-export--md-line "Updated" .updated)
                       (forge-export--md-line "Closed" .closed)
                       (forge-export--md-line "Base" .base_ref)
                       (forge-export--md-line "Head" .head_ref)))
                "")
     "\n## Body\n\n"
     (or .body "")
     "\n\n## Comments\n\n"
     (if (not (forge-export--empty-p .comments))
         (mapconcat
          (lambda (comment)
            (let-alist comment
              (format "### %s at %s\n\n%s\n" .author .created (or .body ""))))
          .comments "\n")
       "No comments.\n")
     (when (not (forge-export--empty-p .review_threads))
       (concat
        "\n## Review Threads\n\n"
        (mapconcat
         (lambda (thread)
           (let-alist thread
             (concat
              (format "### %s:%s\n\n" (or .path "unknown path") (or .line .original_line "unknown line"))
              (mapconcat
               (lambda (comment)
                 (let-alist comment
                   (format "#### %s at %s\n\n%s\n" .author .created (or .body ""))))
               .comments "\n"))))
         .review_threads "\n"))))))

(defun forge-export--write-json (path data)
  (with-temp-file path
    (insert (json-encode data))
    (insert "\n")))

(defun forge-export--write-markdown (path data)
  (with-temp-file path
    (insert (forge-export--markdown data))))

(defun forge-export--self-test ()
  (let* ((dir (make-temp-file "forge-export-self-test-" t))
         (data '((provider . "github")
                 (repo . "owner/repo")
                 (type . "pullreq")
                 (number . 1)
                 (title . "Example")
                 (author . "alice")
                 (body . "Body")
                 (comments . [((author . "bob") (created . "now") (body . "Comment"))])
                 (review_threads . [((path . "file.el")
                                      (line . 10)
                                      (comments . [((author . "carol")
                                                    (created . "now")
                                                    (body . "Review"))]))]))))
    (forge-export--write-json (expand-file-name "topic.json" dir) data)
    (forge-export--write-markdown (expand-file-name "topic.md" dir) data)
    (princ (format "Self-test wrote %s\n" dir))))

(defun forge-export-main ()
  (let ((opts (forge-export--parse-args)))
    (if (forge-export--opt opts 'self-test)
        (forge-export--self-test)
      (forge-export--setup-packages)
      (let* ((repo (forge-export--resolve-repo
                    (forge-export--opt opts 'repo)
                    (forge-export--opt opts 'refresh)))
             (type (forge-export--opt opts 'type))
             (number (if (equal (forge-export--opt opts 'number) "latest")
                         (forge-export--latest-number repo type)
                       (string-to-number (forge-export--opt opts 'number))))
             (_ (unless (> number 0) (error "--number must be positive")))
             (topic (if (forge-export--opt opts 'refresh)
                        (forge-export--query-topic repo type number)
                      (forge-export--cached-topic repo type number)))
             (_ (unless topic (error "Topic not found in Forge cache")))
             (reviews (when (and (equal type "pullreq")
                                  (forge-export--opt opts 'review-threads))
                        (forge-export--review-threads repo number)))
             (extra (when (forge-export--opt opts 'refresh)
                      (forge-export--topic-extra repo type number)))
             (data (forge-export--topic-alist repo topic type reviews extra))
             (out-dir (forge-export--opt opts 'out-dir))
             (format (forge-export--opt opts 'format)))
        (make-directory out-dir t)
        (when (member format '("json" "both"))
          (forge-export--write-json (expand-file-name "topic.json" out-dir) data))
        (when (member format '("markdown" "both"))
          (forge-export--write-markdown (expand-file-name "topic.md" out-dir) data))
        (princ (format "Exported %s #%s to %s\n" type number out-dir))))))

(condition-case err
    (forge-export-main)
  (error
   (princ (format "forge-export: %s\n" (error-message-string err)))
   (kill-emacs 1)))

;;; forge-export.el ends here
