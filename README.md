S3-Rails &mdash; Store templates on AWS:S3
===================================================

[![Gem
Version](https://badge.fury.io/rb/s3_rails.png)](http://badge.fury.io/rb/s3_rails)
[![Dependency Status](https://gemnasium.com/straydogstudio/s3_rails.png?branch=master)](https://gemnasium.com/straydogstudio/s3_rails)
[![Coverage Status](https://coveralls.io/repos/straydogstudio/s3_rails/badge.png)](https://coveralls.io/r/straydogstudio/s3_rails)

##About

S3-Rails is a Rails resolver that retrieves templates from Amazon's S3 service. Imagine moving your `app/views` folder into an Amazon S3 bucket and serving the content from there. The contents of the bucket are cached and can be refreshed.

This is particularly useful when you wish to change templates without re-releasing your application (e.g. Heroku slugs.)

##Future Possibilities

- Pattern matching to exclude/include bucket files (right now *all* files in a bucket are loaded.)
- A single central cache for multiple Rails instances.
- Multiple buckets per Rails app
- (Submit an issue to put your idea here)

##Installation

In your Gemfile:

```ruby
gem 's3_rails'
```

##Requirements

* Rails 3.2

##Usage

Add a `config/s3_rails.yml` file to your Rails app with the following content ([see below](#s3-bucket-and-iam-policies) for policy examples):

```yaml
s3_rails:
  access_key_id: YOUR_S3_ACCESS_KEY
  secret_access_key: YOUR_SECRET_ACCESS_TOKEN
  bucket: 'bucket-name'
  region: 'us-west-2'
```

Then, in your controller, configure it to use the resolver:

```ruby
append_view_path S3Rails::Resolver.instance
```

You can place that in `ApplicationController` to add it to all controllers at once.

###Conflicts

If you have a local copy of the template it will be returned instead of the S3 template. This behavior is inherent to Rails. You must remove the local template for the S3 copy to be returned.

###Reload cache

To reload the template cache upon the next request touch the `tmp/s3_rails.txt` file.

Or, somewhere inside your code (e.g. inside a controller action), call:

```ruby
S3Rails::Resolver.instance.reload
```

##S3 Bucket and IAM Policies:

With this gem, you move the contents of the `app/views` directory to an S3 bucket. You should use Identity and Access Management to create a single user that has read only access to the bucket. That user's credentials should go into the `s3_rails.yml` file.

If you moved an `app/views/posts` directory into a 'my_app' bucket, you would use the following two credentials:

To list the bucket contents:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::my_app"
    }
  ]
}
```

To read the bucket contents:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::my_app/*"
    }
  ]
}
```

##Dependencies

- [Rails](https://github.com/rails/rails)
- [Aws-sdk](http://aws.amazon.com/sdk-for-ruby/)

##Authors

* [Noel Peden](https://github.com/straydogstudio)

##Change log

- **September 8, 2014**: 0.1.1 - Resolver reload method
- **September 8, 2014**: 0.1.0 - Initial release
