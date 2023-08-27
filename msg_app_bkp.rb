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
			puts "Messages from #{channel.class.to_s}"
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

	def create_broadcast_message type, content
		msg = Message.new type, content, nil
		puts "Server created new broadcast message: '#{msg.content}'"
		return msg
	end

	def send_message message, channel
		if message.user.subscribed?(channel)
			puts "Message (id: #{message.id}) sent on #{channel.class.to_s}"	
			channel.update(message) 
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
	# has_one :cotent_type
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

	def save
		case(type)
		when 'text/plain'
		when 'blob'
			# self.image_store(content)
		when 'video/*'
		end
	end
end

# Amazon s3 / hdfs storage
class ImageStore
	def initialize
		
	end
end

# Amazon s3
class VideoStore
	def initialize
		
	end
end

# ES
class TextStore
	def initialize
		
	end
end

## To handle error logging, retries if a channel is down and cant update its queue.
class BaseChannel
	RETRY_LIMIT = 3
	def initialize
	end

	def update msg
		puts "\nSorry!, #{self.class} channel is not available"
		public_send("#{self.class}_retry_queue", msg, self)
	end

	def SMSChannel_retry_queue msg, channel
		@sms_retries ||= {}
		@sms_retries[msg.id] = {retry_count: 0} if @sms_retries[msg.id].nil?
		if @sms_retries[msg.id][:retry_count] < RETRY_LIMIT
			puts @sms_retries.inspect
			puts "\t\t Retrying to deliver sms.."
			# msg.add_to_channel channel
			@sms_retries[msg.id][:retry_count] += 1
		else
			puts "\t\t Logging msg delivery failure"
			@sms_retries.delete(msg.id)
		end
		puts @sms_retries.inspect
	end

end

## could SMS, whatsapp, email channels be presented as -
## modules ? No. Because then update methods will be overridden with the last module to be included 
## 			and specific operations per channel will not be carried out
## singleton classes ? No. There is no added benefit to using singleton class for msg queuing. 
## 					Concurrent access to a queue is fine as each message will be uniquely identified.
class SMSChannel < BaseChannel
	@@message_queue = []
	def initialize
		## Queue should not be reset on each initialize
		## Here we get the handler for actual msg queue like Kafka / Redis 
	end

	def message_queue
		@@message_queue
	end

	def update msg
		@@message_queue << msg
		puts "\tSMSChannel: updated msg '#{msg.content}'"
	end

	def read_messages user
		user_messages = []
		@@message_queue.each do |msg|
			user_messages << msg if msg.user == user || msg.user.nil?
			puts "\t#{msg.type} message recieved: '#{msg.content}'"
		end
		@@message_queue = @@message_queue - user_messages
		return user_messages
	end
end

class WhatsAppChannel < BaseChannel
	@@message_queue = []
	def initialize
		## Here we get the handler for actual msg queue like Kafka / Redis 
	end

	def message_queue
		@@message_queue
	end

	def update msg
		@@message_queue << msg
		puts "\tWhatsAppChannel: updated msg '#{msg.content}'"
	end

	def read_messages user
		user_messages = []
		@@message_queue.each do |msg|
			user_messages << msg if msg.user == user || msg.user.nil?
			puts "\t#{msg.type} message recieved: '#{msg.content}'"
		end
		@@message_queue = @@message_queue - user_messages
		return user_messages
	end
end

class EmailChannel < BaseChannel
	@@message_queue = []
	def initialize
		## Here we get the handler for actual msg queue like Kafka / Redis 
	end

	def message_queue
		@@message_queue
	end

	def update msg
		@@message_queue << msg
		puts "\tEmailChannel: updated msg '#{msg.content}'"
	end

	def read_messages user
		user_messages = []
		@@message_queue.each do |msg|
			user_messages << msg if msg.user == user || msg.user.nil?
			puts "\t#{msg.type} message recieved: '#{msg.content}'"
		end
		@@message_queue = @@message_queue - user_messages
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
# msg2 = msgServer.create_message('blob', 'Picture uploaded', user)
msg2 = msgServer.create_broadcast_message('blob', 'Picture uploaded')
msgServer.broadcast(msg2)
puts '---------'
user.receive_message sms
puts '---------'
user.receive_message whatsapp