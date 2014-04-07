# ![S3](https://raw.github.com/digilord/Meteor-S3-Progress/master/aws-icon.jpg) S3 Progress
This package provides a simple way of uploading files to the Amazon S3 service. This is useful for uploading images and files that you want accesible to the public. The package is built on [Knox](https://github.com/LearnBoost/knox), a module that becomes available server-side after installation.

## Looking for UI Comments
I don't think I am a great user interface designer. I put things together in a way that, to me, makes sense. Is there a better way? I know how to turn a wireframe into an interface. Are any of the github people who starred or are watching this repository able to assist with improving the interface used here?

![S3 Wireframe](https://raw.github.com/digilord/Meteor-S3-Progress/master/images/wireframe.png)

##Features

* Progress bar
* Per user S3 configuration.
* Application wide S3 configuration.
* Configure via code or configuration view.
* Roles for `s3_admin` and `s3_user` are provided via the Roles package.

## Installation

```
mrt add S3-Progress
```

## Requirements
This package makes use of the following packages:

 - roles
 - accounts-base
 - accounts-password
 - momentjs
 - bootboxjs
 - collection-hooks
 - router

All the styling is done via [Bootstrap](http://getbootstrap.com/), but I didn't make the bootstrap package a dependency.  That way you, the pacakge user, can style it as you see fit. You can `mrt add bootstrap-3` to see what the default styles I picked are.

### Specific Package Settings
***Failure to adhere to the settings for individual packages listed below will result in the S3-Progress package to perform poorly or erratically.***

##### accounts-base
This package requires that you use `accounts-base` with the following options.

```
Accounts.ui.config({
  passwordSignupFields: 'USERNAME_AND_EMAIL'
});
```

These settings ensure that the package has the proper fields in a user document to work with.

## Installation & Setup
In order to use the S3 package you need to provide some information.  This information is stored in a collection on your server.  

Add in the `{{> s3config}}` template below to a view to add the required credentials and application level settings.


#### Templates

##### s3upload

Add `{{> s3upload}}` to the template where you would like the upload HTML to reside.

![s3upload template](https://raw.github.com/digilord/Meteor-S3-Progress/master/images/s3upload.png)

#### s3list_of_user
Add `{{> s3list_of_user}}` for a listing of the logged in users files in the S3Files
collection.

![s3upload template](https://raw.github.com/digilord/Meteor-S3-Progress/master/images/s3list_of_user.png)

##### s3list_all
Add `{{> s3list_all}}` for a listing off all the files in S3 for this application.

![s3list_all template](https://raw.github.com/digilord/Meteor-S3-Progress/master/images/s3list_all.png)

##### s3config
Add `{{> s3config}}` to access the configuration options for the package. You, the application developer, should protect this in your templates. 

**Failure to protect this view WILL result in the credentials for your S3 bucket 
for this application to be exposed to the Internet at large.**

![s3config template](https://raw.github.com/digilord/Meteor-S3-Progress/master/images/s3config.png)

##### s3config_admin_users
Add `{{> s3config_admin_users}}` to administer the users permissions for the package. 
![s3config_admin_users template](https://raw.github.com/digilord/Meteor-S3-Progress/master/images/s3config_admin_users.png)

#### s3config_user
Add `{{> s3config_user}}` to your user profile edit view to allow users to add in
 their own S3 configuration. (This doesn't exist yet.)

#### URLS
In an effort to make it easy for application developers to manage the S3 package and expose the features offered I have added some URL targets for use in your application.

##### Amazon S3 URLs
URLs that are specific to the Amazon S3 service.

 - /s3/cors_configuration.xml - The configuration for the Amazon S3 CORS permissions.
 - /s3/bucket_policy_configuration.json - The configuration for the Amazon S3 bucket policy.

##### General Package URLs
I will add URLs to this section as requested by developers.

### Hooks
When a user is removed from the application all files that the user added to the general application file store are removed.

Files that are stored in a private user store are only removed if the user has chosed to have them removed in the event that their account is removed from the application. This would allow a user to keep any assets that were uploaded via your application in the event they want to move to another service.

### Resetting the Collections
To reset the collections used by this package run the following commands in the `meteor mongo` shell.

```
db.s3config.remove()
db.s3files.remove()
```

Those commands will remove all entries from those collections allowing you to start fresh.

## Amazon S3 Setup
For all of this to work you need to create an aws account. On their website create navigate to S3 and create a bucket. Navigate to your bucket and on the top right side you'll see your account name. Click it and go to Security Credentials. Once you're in Security Credentials create a new access key under the Access Keys (Access Key ID and Secret Access Key) tab. This is the info you will use for the first step of this plug. Go back to your bucket and select the properties OF THE BUCKET, not a file. Under Static Website Hosting you can Enable website hosting, to do that first upload a blank index.html file and then enable it. YOU'RE NOT DONE.

#### CORS Setup
You need to set permissions so that everyone can see what's in there. Under the Permissions tab click Edit CORS Configuration and paste this:

```
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <CORSRule>
        <AllowedOrigin>*</AllowedOrigin>
        <AllowedMethod>GET</AllowedMethod>
    </CORSRule>
</CORSConfiguration>
```

#### Bucket Policy
Save it. Now click Edit bucket policy and paste this, REPLACE THE BUCKET NAME WITH YOUR OWN:

```
{
	"Version": "2008-10-17",
	"Statement": [
		{
			"Sid": "AllowPublicRead",
			"Effect": "Allow",
			"Principal": {
				"AWS": "*"
			},
			"Action": "s3:GetObject",
			"Resource": "arn:aws:s3:::YOURBUCKETNAMEHERE/*"
		}
	]
}
```

#### Users
I recommend setting up an AWS Identity and Access Management (IAM) user per application.  Please refer to the AWS documentation on how to add a user.

## Credits
Forked from original work done by [Lepozepo/S3](https://github.com/Lepozepo/S3). At this point in the packages life I have re-written nearly all of the internals. I only mention the original author to give credit where credit is due.

 * [jayfallon](https://github.com/jayfallon) - End user testing and documentation contributions
 * [Yahkob](https://github.com/jayfallon) - Code review and documentation contributions

## To Do
- Complete ability to have folders.
- Allow end users to set a session variable to nest items within a bucket.

## Development
If you want to contribute to the project here is how to set things up.

1. Clone the repo
2. `cd example`
3. `mrt install` This installs all the required packages
4. `meteor` Start meteor.
5. Add a user via the Sign In/Sign Up button.

The example application will prompt you to specify a user to add the `s3_admin` role to. You need to use the same username you used when you signed up.

Next the example application will show you the setup views. You should have already setup an AWS S3 bucket and credentials.

### Reset Mongo
To reset the mongo database used in the example application run `meteor reset`. This will remove ALL collections used in the example applicaiton. It WILL NOT remove any files you have uploaded to S3.

## Support
You have a few options for getting support:

 - File an issue
 - IRC channel \#s3-progress on freenode
 - Send a message to me on Twitter @digilord

## License
The MIT License (MIT)

Copyright (c) 2013 D. Allen Morrigan

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Donating
By donating you are supporting this package and its developer so that he may continue to bring you updates to this and other software he maintains.

[![Support us via Gittip][gittip-badge]][digilord]

[gittip-badge]: https://rawgithub.com/digilord/gittip-badge/master/dist/gittip.png
[digilord]: https://www.gittip.com/digilord/
