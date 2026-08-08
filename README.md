# Portafilter
*pulls the attachment, discards the email*

Pipeline for getting your email attachments to where you want them. 

1) Listens for new mail on an IMAP folder
2) Pulls the content locally
3) Extracts and saves attachments to mounted volume
4) Deletes the email from the mailbox


### Example use cases
* Long-term storage of bills, receipts, etc. on your NAS
* Getting email attachments into a paperless-type software's ingestion folder

### Quick start
```
docker run \
  --name portafilter \
  -v /path/to/storage:/output \
  ghcr.io/jeremyrea/portafilter:latest
```

### Required Environment variables

| Name              | Default value |
| ----------------- | ------------- |
| **IMAP_SERVER**   |       -       |
| **IMAP_USERNAME** |       -       |
| **IMAP_PASSWORD** |       -       |
| **LISTEN_FOLDER** |       -       |
