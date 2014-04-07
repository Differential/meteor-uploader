S3files = new Meteor.Collection('s3files');

S3files.before.insert(function (userId, doc) {
  doc.createdAt = Date.now();
});

S3files.before.update(function (userId, doc, fieldNames, modifier /* , options */) {
  modifier.$set.modifiedAt = Date.now();
});