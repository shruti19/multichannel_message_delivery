Design and implement a multi-channel notification service which supports sending text, image, audio and video content through email, sms, whatsapp, slack, etc.

Functional requirements -

Send customisable notifications with different types of content
Send notifications through different channels
Ability to add new channels and content-types per channel

Send notifications based on user’s saved preferences
Single/simple and bulk notification messages
Prioritise notifications

*****************************
Demo:
*****************************

INPUT:
-------------------------------------------------------
```
msgServer = MessageServer.new
sms = SMSChannel.new
whatsapp = WhatsAppChannel.new
email = EmailChannel.new
msgServer.add_channel(sms)
msgServer.add_channel(whatsapp)
msgServer.add_channel(email)
puts '---------'
user = User.new('Ram', 'ram@gmail.com', 7889900112)
user.subscribe(sms)
user.subscribe(whatsapp)
puts '---------'
msg1 = msgServer.create_message('text/plain', 'Hi, this is Ram!', user)
msgServer.send_message(msg1, sms)

## There should have been another method here to create a broadcast message which doesnt require user info.
msg2 = msgServer.create_message('blob', 'Picture uploaded', user)
msgServer.broadcast(msg2)
puts '---------'
user.receive_message sms
puts '---------'
user.receive_message whatsapp
````

OUTPUT:
-------------------------------------------------------

Server added SMSChannel
Server added WhatsAppChannel
Server added EmailChannel
---------
User Subscribed to: SMSChannel
User Subscribed to: WhatsAppChannel
---------
Server created new message: 'Hi, this is Ram!' for Ram
Message (id: lplrqpdmb) sent on SMSChannel
	SMSChannel: updated msg 'Hi, this is Ram!'
Server created new message: 'Picture uploaded' for Ram
Message (id: ohcguwyer) broadcasting on all channels..
	SMSChannel: updated msg 'Picture uploaded'
	WhatsAppChannel: updated msg 'Picture uploaded'
	EmailChannel: updated msg 'Picture uploaded'
---------
User (Ram) listening ..
Messages from SMSChannel
	text/plain message recieved: 'Hi, this is Ram!'
	blob message recieved: 'Picture uploaded'
Messgaes ["Hi, this is Ram!", "Picture uploaded"]
---------
User (Ram) listening ..
Messages from WhatsAppChannel
	blob message recieved: 'Picture uploaded'
Messgaes ["Picture uploaded"]
[Finished in 0.5s]