Nothing private in this file, I just don't want github to scrape blog urls and
people's names

# Encrypt feeds
gpg -c feeds

# Decrypt feeds
gpg -d feeds.gpg > feeds
