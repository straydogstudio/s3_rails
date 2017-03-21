S3-Rails &mdash; Store templates on AWS:S3
===================================================

[![Gem
Version](https://badge.fury.io/rb/s3_rails.png)](http://badge.fury.io/rb/s3_rails)
[![Dependency Status](https://gemnasium.com/straydogstudio/s3_rails.png?branch=master)](https://gemnasium.com/straydogstudio/s3_rails)
[![Coverage Status](https://coveralls.io/repos/straydogstudio/s3_rails/badge.png)](https://coveralls.io/r/straydogstudio/s3_rails)

## About

S3-Rails is a Rails resolver that retrieves templates from Amazon's S3 service. Imagine moving files from your `app/views` folder into an Amazon S3 bucket and serving them from there. The contents of the bucket are cached and can be refreshed.

This is particularly useful when you wish to change templates without re-releasing your application (e.g. Heroku slugs.)

### So What Exactly Does This Do?

By default Rails searches the `app/views` folder for templates. You can, however, have it search multiple places, from almost any location. (For instance, in [Crafting Rails Applications](https://pragprog.com/book/jvrails2/crafting-rails-applications) Jos&eacute; Valim shows how to serve templates from a database.) S3-Rails adds an S3 bucket to this list of places. 

For a given request, Rails uses the action name, extension, locale, variant, and available renderer list to generate a list of matching templates. In general the first one returned is rendered. The S3-Rails gem searches the configured bucket and returns matching templates for Rails to render. If a local template is not found first, Rails will render and serve the S3 template. 

## Future Possibilities

- Pattern matching to exclude/include bucket files (right now *all* files in a bucket are loaded.)
- A single central cache for multiple Rails instances (think Heroku.)
- Multiple buckets per Rails app (matched to controller/action?)
- (Submit an issue to put your idea here)

## Installation

In your Gemfile:

```ruby
gem 's3_rails'
```

## Requirements

* Rails 3.2

## Usage

### Set up Your Bucket

Create an S3 bucket, placing templates inside it as if it were the `app/views` directory. For instance, if you had an `app/views/reports/yearly_report.pdf.prawn` file, you would move it to `reports/yearly_report.pdf.prawn` inside the S3 bucket.

Now create an individual user under your Identity and Access Management AWS console, and give read only access to your bucket [using policies](#s3-bucket-and-iam-policies).

### Configure S3

Add a `config/s3_rails.yml` file to your Rails app with the following content ([see below](#s3-bucket-and-iam-policies) for policy examples):

```yaml
s3_rails:
  access_key_id: YOUR_S3_ACCESS_KEY
  secret_access_key: YOUR_SECRET_ACCESS_TOKEN
  bucket: 'bucket-name'
  region: 'us-west-2'
```

When you created your bucket you will have specified the region. The access key and secret access key are specific to the user account used to access the bucket. 

You can use ERB in this file to access environment variables:

```yaml
  access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
  secret_access_key: <%= ENV['AWS_SECRET_ACCESS_KEY'] %>
```

### Controller

Then, in your controller, configure it to use the resolver:

```ruby
append_view_path S3Rails::Resolver.instance
# or, to search S3 before the file system
prepend_view_path S3Rails::Resolver.instance
```

You can place that in `ApplicationController` to add it to all controllers at once.

### Restart

Then restart your app if needed.

### Reload cache

To reload the template cache upon the next request touch the `tmp/s3_rails.txt` file.

Or, somewhere inside your code (e.g. inside a controller action), call:

```ruby
S3Rails::Resolver.instance.reload
```

## Troubleshooting

### Conflicts

If you use `append_view_path` and you have a local copy of the template it will be returned instead of the S3 template. This behavior is inherent to Rails. You must remove the local template for the S3 copy to be returned, unless you use `prepend_view_path`, which will make Rails call S3 before searching the local directory.

## S3 Bucket and IAM Policies:

With this gem, you move the contents of the `app/views` directory to an S3 bucket. You should use Identity and Access Management to create a single user that has read only access to the bucket. That user's credentials should go into the `s3_rails.yml` file.

If you moved a view directory into a 'my_app' bucket, you would use the following two credentials:

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

## Credit

[David Burton](https://github.com/burtondav) asked me for this quite a while ago, and the idea simmered until I read [Crafting Rails Applications](https://pragprog.com/book/jvrails2/crafting-rails-applications) by Jos&eacute; Valim. Then I wrote most of this code while recording the ["Rails Rendering" for Pluralsight](http://pluralsight.com/courses/rails-rendering). It seemed useful enough to make a gem of it. Many thanks to all of them!

## Dependencies

- [Rails](https://github.com/rails/rails)
- [Aws-sdk](http://aws.amazon.com/sdk-for-ruby/)

## Authors

* [Noel Peden](https://github.com/straydogstudio)

## Change log

- **October 1, 2014**: 0.1.2 - ERB for config file
- **September 8, 2014**: 0.1.1 - Resolver reload method
- **September 8, 2014**: 0.1.0 - Initial release
