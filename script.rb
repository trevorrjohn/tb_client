ENV['RUBY_FFI_DEBUG'] = '1'
require_relative "lib/tb_client"

client = TBClient::Client.new(addresses: '3000', cluster_id: 0, client_id: 1)
status = client.connect

puts status
ledger = 1
code = 10
account1_id = TBClient::Types::UINT128.to_native(1, nil)
account1 = TBClient::Bindings::Account.new
account1[:id] = account1_id
account1[:ledger] = ledger
account1[:code] = code

account2_id = TBClient::Types::UINT128.to_native(2, nil)
account2 = TBClient::Bindings::Account.new
account2[:id] = account2_id
account2[:ledger] = ledger
account2[:code] = code

account_data = FFI::MemoryPointer.new(TBClient::Bindings::Account, 2)
account_data.put_bytes(0, account1.pointer.read_bytes(TBClient::Bindings::Account.size))
account_data.put_bytes(TBClient::Bindings::Account.size, account2.pointer.read_bytes(TBClient::Bindings::Account.size))

user_data = FFI::MemoryPointer.new(FFI::Type::UINT64, 1)
user_data.write_uint64(2)

packet = TBClient::Bindings::Packet.new
packet[:user_data] = user_data
packet[:data] = account_data
packet[:data_size] = account_data.size
packet[:status] = TBClient::Bindings::PacketStatus[:OK]
packet[:operation] = TBClient::Bindings::Operation[:CREATE_ACCOUNTS]

user_data = FFI::MemoryPointer.new(FFI::Type::UINT64, 1)
user_data.write_uint64(10)
pulse = TBClient::Bindings::Packet.new
pulse[:user_data] = user_data
pulse[:status] = TBClient::Bindings::PacketStatus[:OK]
pulse[:operation] = TBClient::Bindings::Operation[:PULSE]


puts "*"  * 50

status = client.submit(packet, TBClient::Bindings::CreateAccountsResult) do |result|
  puts result
end


puts status

10.times do
  sleep 1
  puts "Sleeping"
end
