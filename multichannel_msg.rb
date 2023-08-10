class User
	attr_accessor :subscribed_channels, :name

	def initialize name, email, phone
		@id = (0...9).map { ('a'..'z').to_a[rand(26)] }.join
		@name = name
		@email = email
		@phone = phone
		@subscribed_channels = []
	end

	def subscribed? channel
		@subscribed_channels.include?(channel.class.to_s)
	end

	def subscribe channel
		if !@subscribed_channels.include?(channel.class.to_s)
			@subscribed_channels << channel.class.to_s
		end
		puts "User Subscribed to: #{channel.class.to_s}"
	end

	def unsubscribe channel
		if @subscribed_channels.include?(channel.class.to_s)
			@subscribed_channels.delete(channel.class.to_s)
		end
		puts "User Subscribed channels: #{@subscribed_channels.inspect}"
	end

	def receive_message channel
		puts "User (#{name}) listening .."
		if @subscribed_channels.include?(channel.class.to_s)
			puts "Messgae from #{channel.class.to_s}"
			msgs = channel.read_messages self
			msgs[0] ? (puts "Messgaes #{msgs.map(&:content)}") : (puts "No messages on #{channel.class.to_s}")
		end
	end

	def get_id
		@id
	end
end

class MessageServer
	def initialize
		@channels = []
	end

	def add_channel channel
		@channels << channel
		puts "Server added #{channel.class}"
	end

	def create_message type, content, user
		msg = Message.new type, content, user
		puts "Server created new message: '#{msg.content}' for #{user.name}"
		return msg
	end

	def send_message message, channel
		if message.user.subscribed?(channel)
			channel.update(message) 
			puts "Message (id: #{message.id}) sent on #{channel.class.to_s}"	
		end	# if user has not subscribed, will print error
	end

	def broadcast message
		puts "Message (id: #{message.id}) broadcasting on all channels.."		
		@channels.each do |ch|
			# if message.user.subscribed?(ch)
			ch.update(message) 
			# end	
		end	
	end
end

class Message
	attr_reader :content, :id, :type
	def initialize type, content, user
		@id = (0...9).map { ('a'..'z').to_a[rand(26)] }.join
		@type = type
		@content = content
		@to = user
	end

	def add_to_channel channel
		channel.message_queue << self
	end

	def user
	  	@to	
	end
end

class BaseChannel
	def initialize
		
	end

	def update msg
		puts "Sorry!, channel is not available"
	end

end

class SMSChannel < BaseChannel
	def initialize
		@message_queue = []
	end

	def message_queue
		@message_queue
	end

	def update msg
		@message_queue << msg
		puts "SMSChannel: updated msg id #{msg.id}"
	end

	def read_messages user
		user_messages = []
		@message_queue.each do |msg|
			user_messages << msg if msg.user == user
			puts "#{msg.type} message recieved: #{msg.content}"
		end
		@message_queue = @message_queue - user_messages
		return user_messages
	end
end

class WhatsAppChannel < BaseChannel
	def initialize
		@message_queue = []
	end

	def message_queue
		@message_queue
	end

	def update msg
		@message_queue << msg
		puts "WhatsAppChannel: updated msg id: #{msg.content}"
	end

	def read_messages user
		user_messages = []
		@message_queue.each do |msg|
			user_messages << msg if msg.user == user
			puts "#{msg.type} message recieved: #{msg.content}"
		end
		@message_queue = @message_queue - user_messages
		return user_messages
	end
end

class EmailChannel < BaseChannel
	def initialize
		@message_queue = []
	end

	def message_queue
		@message_queue
	end

	def update msg
		@message_queue << msg
		puts "EmailChannel: updated msg id: #{msg.id}"
	end

	def read_messages user
		user_messages = []
		@message_queue.each do |msg|
			user_messages << msg if msg.user == user
			puts "#{msg.type} message recieved: #{msg.content}"
		end
		@message_queue = @message_queue - user_messages
		return user_messages
	end
end

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