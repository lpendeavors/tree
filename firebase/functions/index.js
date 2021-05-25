const functions = require('firebase-functions');
const admin = require('firebase-admin');

const app = admin.initializeApp();
const db = admin.firestore();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.markChatsRead = functions.https.onCall(async (data, context) => {
    const userId = data.user;
    const groupId = data.group;

    functions.logger.info(`Marking chats read for group ${groupId}`);

    const chatCollectionRef = db.collection('chatBase');
    const chatMessages = await chatCollectionRef
      .where('chatId', '==', groupId)
      .where('parties', 'array-contains', userId)
      .get();

    chatMessages
      .docs()
      .filter(m => !m.readBy.contains(userId))
      .forEach(async (m) => {
        await m.ref.update({
          'readBy': admin.firestore.FieldValue.arrayUnion(userId),
        });
    });

    functions.logger.info(`Update successful`);

    return true;
});

exports.groupUpdated = functions.firestore.document('groupBase/{documentId}')
    .onUpdate(async (snapshot, context) => {
        const original = snapshot.before.data();
        const updated = snapshot.after.data();

        // When joining group, subscribe to last chat message
        if ((original.parties || []).length < (updated.parties || []).length) {
            const newMember = updated.parties.filter(p => !original.parties.includes(p))[0];
            functions.logger.info(`Parties updated... Added ${newMember}`);

            const chatCollectionRef = db.collection('chatBase');
            const groupMessage = await chatCollectionRef
                .where('chatId', '==', context.params.documentId)
                .orderBy('createdAt', 'desc').limit(1).get();
            functions.logger.info(`Found ${groupMessage.docs.length} group message...`);

            if (groupMessage.docs.length > 0) {
                const chatId = groupMessage.docs[0].id;
                functions.logger.info(`Subscribing to chat ${chatId}`);

                await db.doc(`chatBase/${chatId}`).update({
                    'parties': admin.firestore.FieldValue.arrayUnion(newMember),
                });

                functions.logger.info(`Update successful`);
            }
        }

        // When leaving group, unsubscribe to all chat messages
        if ((original.parties || []).length > (updated.parties || []).length) {
            const oldMember = original.parties.filter(p => !updated.parties.includes(p))[0];
            functions.logger.info(`Parties updated... Removed ${oldMember}`);

            const chatCollectionRef = db.collection('chatBase');
            const groupMessages = await chatCollectionRef.where('chatId', '==', context.params.documentId).get();
            functions.logger.info(`Found ${groupMessages.length} group messages. Unsubscribing...`);

            if (groupMessages.length > 0) {
                groupMessages.forEach(async (message) => {
                    await message.ref.update({
                        'parties': admin.firestore.FieldValue.arrayRemove(newMember),
                    });
                });
            }

            functions.logger.info(`Update successful`);
        }
    });

exports.groupRemoved = functions.firestore.document('groupBase/{documentId}')
    .onDelete(async (snapshot, context) => {
        functions.logger.info(`Room deleted. Finiding messages...`);
        const chatMessagesRef = db.collection('chatBase');
        const chatMessages = await chatMessagesRef.where('chatId', '==', context.params.documentId).get();

        functions.logger.info(`Found ${chatMessages.docs.length} messages. Deleting...`);
        chatMessages.docs.forEach(async (doc) => {
            await doc.ref.delete();
        });

        functions.logger.info('Delete complete');
    });


exports.userUpdated = functions.firestore.document('userBase/{documentId}')
    .onUpdate(async (snapshot, context) => {
        const original = snapshot.before.data();
        const updated = snapshot.after.data();

        // When adding new connection, add new follower to existing posts
        if ((original.connections || []).length < (updated.connections || []).length) {
            const newConnection = updated.connections.filter(c => !original.connections.includes(c))[0];
            functions.logger.info(`Connections updated... Added ${newConnection}`);

            const postCollectionRef = db.collection('postBase');
            const newConnectionPosts = await postCollectionRef.where('ownerId', '==', newConnection).get();
            functions.logger.info(`${newConnectionPosts.docs.length} posts found. Updating...`);

            newConnectionPosts.docs.forEach(async (doc) => {
                await db.doc(`postBase/${doc.id}`).update({
                    'parties': admin.firestore.FieldValue.arrayUnion(context.params.documentId)
                });
            });

            functions.logger.info('Update complete');
        }

        // When removing connection, unfollow the posts
        if ((original.connections || []).length > (updated.connections || []).length) {
            const oldConnection = original.connections.filter(c => !updated.connections.includes(c))[0];
            functions.logger.info(`Connections updated... Removed ${oldConnection}`);

            const postCollectionRef = db.collection('postBase');
            const oldConnectionPosts = await postCollectionRef.where('ownerId', '==', oldConnection).get();
            functions.logger.info(`${oldConnectionPosts.docs.length} posts found. Updating...`);

            oldConnectionPosts.docs.forEach(async (doc) => {
                await db.doc(`postBase/${doc.id}`).update({
                    'parties': admin.firestore.FieldValue.arrayRemove(context.params.documentId)
                });
            });

            functions.logger.info('Update complete');
        }

        // When friend request is sent
        if ((original.sentRequests || []).length < (updated.sentRequests || []).length) {
          const newRequest = updated.sentRequests.filter(r => !original.sentRequests.includes(r))[0];
          functions.logger.info(`Request sent to ${newRequest}`);

          const fromUserId = context.params.documentId;
          const fromUserRef = db.doc(`userBase/${fromUserId}`);
          const fromUserDoc = await fromUserRef.get();
          const fromUserName = fromUserDoc.data()['isChurch'] ? fromUserDoc.data()['churchName'] : fromUserDoc.data()['fullName'];
          const fromUserImage = fromUserDoc.data()['image'] || "";

          const userRef = db.doc(`userBase/${newRequest}`);
          const userSnap = await userRef.get();
          const token = userSnap.data()['pushNotificationToken'];

          if (token != null) {
            functions.logger.info(`Sending push notification to ${token}`);

            const payload = {
              notification: {
                title: 'You have a friend request',
                body: `${fromUserName} sent you a friend request.`,
                icon: fromUserImage,
              }
            };

            const response = await admin.messaging().sendToDevice(token, payload);

            response.results.forEach((result, index) => {
              const error = result.error;
              if (error) {
                console.error('Failure sending notification to', token, error);
              }
            });
          } else {
            functions.logger.info(`Token not found`);
          }

          // const notificationRef = db.collection('notificationBase');
          // notificationRef.add({

          // })
        }
        
        // When verified status is approved

        // When user is suspended
        // if (!(original.isSuspended || false) && updated.isSuspended) {
        //   admin.auth().updateUser(context.params.documentId, {
        //     disabled: true,
        //   })
        //   .then((userRecord) => {
        //     functions.logger.info(`Disabled user ${userRecord.uid}`);
        //   })
        //   .catch((error) => {
        //     functions.logger.error(error);
        //   });
        // }
    });

// exports.postUpdated = functions.firestore.document('postBase')
//     .onUpdate(async (snapshot, context) => {
//       const original  = snapshot.before.data();
//       const updated = snapshot.after.data();

//       // Check for 
//     });