# if (Meteor.isClient) {
#   Template.hello.greeting = function () {
#     return "Welcome to example.";
#   };

#   Template.hello.events({
#     'click input' : function () {
#       // template data, if any, is available in 'this'
#       if (typeof console !== 'undefined')
#         console.log("You pressed the button");
#     }
#   });
# }

# if (Meteor.isServer) {
#   Meteor.startup(function () {
#     // code to run on server at startup
#   });
# }

Meteor.startup () ->
  if Meteor.isClient
    Accounts.ui.config({
      passwordSignupFields: 'USERNAME_AND_EMAIL'
    })
