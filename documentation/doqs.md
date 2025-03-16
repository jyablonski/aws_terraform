# Doqs

### 1. S3 Bucket Configuration

You have an S3 bucket (`doqs_bucket`), and within it, you store the static assets for your web app (like HTML, CSS, JS, and images). S3 allows you to store files securely, but without CloudFront, these files would be directly accessible via S3’s endpoints, typically using HTTP. Here’s how things work:

- Private S3 Bucket:
  By default, an S3 bucket is private, meaning only the account owner (and anyone specifically granted access) can access the objects inside. You have configured your S3 bucket's public access block to deny public ACLs and deny public policies:

  ```hcl
  resource "aws_s3_bucket_public_access_block" "doqs_public_access_block" {
    bucket = aws_s3_bucket.doqs_bucket.id
    block_public_acls   = true
    block_public_policy = true
  }
  ```

  This means no one can directly access the files in your bucket via S3's URL (which would be something like `https://doqs-bucket-name.s3.amazonaws.com/`).

- Website Hosting on S3:
  Even though the bucket itself is private, you've enabled static website hosting on your S3 bucket. This means S3 can serve your static content (like `index.html`, `style.css`, etc.) but only via the website endpoint (not the typical S3 object URL).

  Example configuration:
  ```hcl
  website {
    index_document = "index.html"
    error_document = "error.html" # Optional, can be configured
  }
  ```

  - The S3 website endpoint (e.g., `http://doqs-bucket-name.s3-website-us-east-1.amazonaws.com`) is a public URL.
  - This endpoint only supports HTTP (not HTTPS), which is why we use CloudFront to provide a secure connection (HTTPS).

  S3 website hosting is useful for serving static content, but direct access to it without CloudFront isn't secure or ideal for production.

### 2. CloudFront Distribution

This is where CloudFront comes into play. CloudFront is an AWS CDN (Content Delivery Network) service that caches your content at edge locations around the world, speeding up access and providing SSL/TLS encryption for HTTPS traffic. Here’s how it fits in:

- CloudFront as a Proxy:
  CloudFront acts as a reverse proxy between users and your S3 bucket. Users access your website via CloudFront (using a custom domain like `doqs.yourdomain.com`), and CloudFront fetches the content from the S3 bucket on their behalf. The process looks like this:

  1. User Request: A user navigates to `https://doqs.yourdomain.com`.
  2. CloudFront Distribution: The request hits CloudFront, which forwards the request to the S3 bucket (via the S3 website endpoint).
  3. S3 Bucket Response: S3 sends the requested file back to CloudFront.
  4. CloudFront Caching: CloudFront caches the content at the edge location for faster future access.
  5. User Response: CloudFront serves the content to the user over HTTPS (if configured).

- CloudFront and HTTPS:
  CloudFront provides HTTPS (secure connection) for users accessing your site. You’ve configured this in your CloudFront distribution by specifying an ACM certificate (SSL certificate) for the domain:

  ```hcl
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.jacobs_website_cert.arn
    ssl_support_method  = "sni-only"
  }
  ```

  This ensures that users access your site securely via `https://doqs.yourdomain.com`. CloudFront will terminate the SSL/TLS connection at the edge location and then communicate with your S3 bucket over HTTP or HTTPS (depending on your configuration).

  - By using HTTPS for CloudFront, the data between the user and CloudFront is encrypted.
  - CloudFront can then communicate with your S3 bucket either over HTTP or HTTPS, depending on the configuration you choose for the S3 origin.

- CloudFront as a CDN:
  - Caching: CloudFront caches the static files at edge locations around the world. If a user from Europe requests the site, CloudFront will serve them the cached content from the nearest edge location (instead of the origin S3 bucket in, say, the US), which speeds up delivery.
  - Security: CloudFront provides better security through SSL/TLS encryption, and you can further restrict access to your S3 bucket by using an Origin Access Identity (OAI), ensuring that only CloudFront can fetch data from S3.

### 3. Public vs Private Access

- S3 Bucket: Your S3 bucket itself is private (i.e., users cannot access it directly). S3’s website hosting endpoint is public, but it only supports HTTP, which is why CloudFront is needed for secure access.
  
- CloudFront Distribution: The content served through CloudFront is publicly accessible (to anyone with the correct URL, like `https://doqs.yourdomain.com`). CloudFront provides secure HTTPS access and handles caching, improving both security and performance.

- What's Public:
  - The CloudFront distribution endpoint (`https://doqs.yourdomain.com`) is public and serves your web app over HTTPS.
  - The S3 website endpoint (`http://doqs-bucket-name.s3-website-us-east-1.amazonaws.com`) is public but only supports HTTP. It’s used by CloudFront to retrieve files.
  
- What's Private:
  - The S3 bucket itself is private, and direct access to the files via the S3 bucket URL is restricted. CloudFront accesses the bucket using its Origin Access Identity (OAI), ensuring that only CloudFront can read from the bucket.
  
### 4. Overall Flow of Content Delivery:

1. User accesses the website:
   - They go to `https://doqs.yourdomain.com`, which is routed to CloudFront.
   
2. CloudFront fetches content:
   - If the content is cached, CloudFront serves it immediately. If not, it fetches the content from the S3 bucket (via the S3 website endpoint or HTTPS, depending on your CloudFront settings).
   
3. Content served over HTTPS:
   - CloudFront ensures that the connection is encrypted via HTTPS, even though the S3 bucket may be accessed over HTTP.

4. Caching:
   - CloudFront caches the content to improve performance and reduce load on the S3 bucket, serving it faster for future requests.

---

### Summary:

- S3 Bucket: Stores static files, private by default, with static website hosting enabled. It’s used to serve files to CloudFront.
- CloudFront: Acts as a proxy, securely serving your website over HTTPS, while fetching content from the S3 bucket (which can be done over HTTP/HTTPS).
- Public/Private:
  - The CloudFront URL is public (accessible to users).
  - The S3 bucket is private, and access is restricted to CloudFront through an OAI.

This setup ensures your site is secure, fast, and scalable! Let me know if you need any further clarification.