# frozen_string_literal: true

require "test_helper"

class TestTBClient < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::TBClient::VERSION
  end

  def callback(client_id, packet, timestamp, result_ptr, result_len)
      request_id = packet[:user_data].read_uint64
      request = inflight_requests[request_id]
      result = deserialize(result_ptr, request.converter, result_len)
      request.block.call(result)
  end

  def test_that_it_works
    client = TBClient::Client.new(address: '3000', cluster_id: 0, client_id: 1)
    status = client.connect
    assert_equal 0, TBClient::Bindings::InitStatus.symbol_map[status]

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

    client.submit(packet, TBClient::Bindings::CreateAccountsResult) do |result|
      binding.irb
      assert false
    end

    10.times do
      sleep 1
    end
    assert false
  end
end
