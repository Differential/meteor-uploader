---
layout: default
username: Differential
repo: meteor-uploader
version: 0.0.1
desc: Upload files to the clouds
---
# meteor-uploader

Renders an upload button so you can upload files from the browser to the cloud (currently only s3)

## Server
#### Configure
{% highlight coffeescript %}
Uploader.config
  key: "my-key"
  secret: "my-secret"
  bucket: "my-bucket"
  directory: "/" # Optional
{% endhighlight %}

#### Usage
{% assign uploader = '{{> Uploader forProfilePic}}' %}
`{{ uploader }}`

{% highlight html %}
<template name="MyTemplate">
  {{uploader}}
</template>
{% endhighlight %}

{% highlight coffeescript %}
Template.MyTemplate.helpers
  forProfilePic: ->
    name: "profilePic" # Unique name per uploader on page
    multiple: true # Optional
    current: Session.get "profilePicUrl" # Optional - shows thumbnail and remove button
    onUpload: (error, result) -> # Callback after uploaded - runs once per file uploaded
      if result
        console.log result
        Session.set "profilePicUrl", result
    onDelete: (error, result) -> # Callback after deleted - runs once per file deleted
      if result
        console.log "Deleted", result
        Session.set "profilePicUrl", null
{% endhighlight %}

## Server
#### Configure
{% highlight coffeescript %}
Billing.config
  secretKey: your_secret_key
{% endhighlight %}


#### Usage
* `createCustomer: (userId, card)` where userId is Meteor's user collection _id and card is the token returned from `Billing.createToken(form)` on the client.  This sets `billing.customerId` and `billing.cardId` on the associated user.
* `createCard: (userId, card)` where card is the token returned from `Billing.createToken(form)` on the client.  This sets `billing.cardId` on the associated user.
* `retrieveCard: (userId, cardId)`
* `deleteCard: (userId)`
* `createCharge: (params)` where params is a hash of options for stripe. ex: `params = amount: amount, currency: 'usd', customer: user.billing.customerId, description: "Something here", statement_description: "WHATEVER"`
* `listCharges: (params)`
* `updateSubscription: (userId, params)` where params is a hash of options for stripe.  ex: `params = plan: 'standard', quantity: quantity, prorate: false, trial_end: someDate`.  This sets `billing.subscriptionId` to the subscription id returned from stripe.
* `cancelSubscription: (customerId)` where customerId is the stripe customer id (`user.billing.customerId`).
* `getInvoices`: Gets a list of past invoices for current user.
* `getUpcomingInvoice`: Gets the next invoice for current user.

## Stripe Configuration
The package provides a basic handler for a few events

* `charge.failed`: Cancels the associated user's subscription.
* `customer.subscription.deleted`: Deletes the subscriptionId and planId from the associated user's `billing` object.
* `customer.deleted`: Deletes the associated user from the database

To use these default handlers, use your stripe dashboard to set the webhooks url to `your_url/api/webhooks`.
You can of course, provide your own handlers instead of using these by pointing the webhooks url to your own implementation.

{% assign if = '{{#if working}}' %}
{% assign endif = '{{/if}}' %}

## Example:
{% highlight html %}
<form novalidate>
  {{cc}}
  <button type="submit" class="btn btn-primary btn-block upgrade" disabled="{{working}}">
    Upgrade Today
    {{if}}
      <i class="fa fa-spinner fa-spin"></i>
    {{endif}}
  </button>
</form>
{% endhighlight %}

{% highlight coffeescript %}
"click button": (e) ->
    e.preventDefault()
    Session.set 'working', true

    Billing.createToken $("form"), (status, response) ->
      if response.error
        Session.set 'error', response.error.message
        Session.set 'working', false
      else
        Meteor.call 'createCustomer', Meteor.userId(), response, (error, response) ->
          Session.set 'working', false
          if error
            Session.set 'error', error.reason
{% endhighlight %}
