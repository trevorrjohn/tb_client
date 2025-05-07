# frozen_string_literal: true

require "ffi"

require_relative "tb_client/shared_lib"
require_relative "tb_client/types"
require_relative "tb_client/ffi_struct_converter"
require_relative "tb_client/bindings"
require_relative "tb_client/version"

module TBClient
  class Error < StandardError; end

  Request = Struct.new(:packet, :result_type, :block) do
    def initialize(packet, result_type, &block)
      super(packet, result_type, block)
    end
  end

  class Client
    def initialize(addresses: "3000", cluster_id: 0, client_id: 1)
      @addresses = addresses.to_s
      @cluster_id = TBClient::Types::UINT128.to_native(cluster_id, nil)
      @client_id = client_id
      @inflight_requests = {}
      @on_completion = Proc.new { |*args| callback(*args) }
      @log_handler = Proc.new do |level, ptr, length|
        puts "#{level}: #{ptr.read_bytes(length)}"
      end

      at_exit do
        if @client
          TBClient::Bindings.tb_client_register_log_callback(nil, false)
          TBClient::Bindings.tb_client_deinit(@client)
          @client = nil
          @inflight_requests = {}
        end
      end
    end

    def connect
      @client = TBClient::Bindings::Client.new

      TBClient::Bindings.tb_client_init(
        @client,
        @cluster_id,
        @addresses,
        @addresses.length,
        @client_id,
        @on_completion
      )

      TBClient::Bindings.tb_client_register_log_callback(@log_handler, true)
    end

    def create_accounts(*accounts)
      request_id = Time.now.to_i
      request_id_ptr = FFI::MemoryPointer.new(FFI::Type::UINT64, 1)
      request_id_ptr.write_uint64(request_id)

      packet = TBClient::Bindings::Packet.new

      packet[:user_data] = request_id_ptr
      account_data = FFI::MemoryPointer.new(TBClient::Bindings::Account, accounts.length)
      accounts.each_with_index do |account, i|
        account_data.put_bytes(i * account.size, account.pointer.read_bytes(account.size))
      end
      packet[:data] = account_data
      packet[:data_size] = account_data.size
      packet[:status] = :OK
      packet[:operation] = TBClient::Bindings::Operation[:CREATE_ACCOUNTS]

      submit(
        packet,
        TBClient::Bindings::CreateAccountsResult,
      )
    end

    def lookup_accounts(*account_ids, &block)
      request_id = Time.now.to_i
      request_id_ptr = FFI::MemoryPointer.new(FFI::Type::UINT64, 1)
      request_id_ptr.write_uint64(request_id)

      packet = TBClient::Bindings::Packet.new
      packet[:user_data] = request_id_ptr

      account_data = FFI::MemoryPointer.new(TBClient::Types::UINT128, account_ids.length)
      account_ids.each_with_index do |id, i|
        uint128 = TBClient::Types::UINT128.to_native(id, nil)
        account_data.put_bytes(i * uint128.size, uint128.read_bytes(uint128.size))
      end
      packet[:data] = account_data
      packet[:data_size] = account_data.size
      packet[:status] = :OK
      packet[:operation] = TBClient::Bindings::Operation[:LOOKUP_ACCOUNTS]

      submit(
        packet,
        TBClient::Bindings::Account,
        &block
      )
    end

    def submit(packet, result_type, &result_block)
      request_id = packet[:user_data].read_uint64
      queue = SizedQueue.new(1)
      @inflight_requests[request_id] = Request.new(packet, result_type) do |result|
        if result_block
          result_block.call(result)
        else
          queue << result
        end
      end

      TBClient::Bindings.tb_client_submit(
        @client,
        packet,
      )

      queue.pop unless result_block
    end

    private

    def callback(client_id, packet, timestamp, result_ptr, result_len)
      request_id = packet[:user_data].read_uint64
      request = @inflight_requests.delete(request_id)
      raise "Request not found for ID: #{request_id}" unless request.is_a?(Request)

      result_type = request.result_type
      results = Array.new(result_len / result_type.size) do |i|
        ptr = FFI::MemoryPointer.new(result_type, 1)
        ptr.put_bytes(0, result_ptr.get_bytes(i * result_type.size, result_type.size))
        result_type.new(ptr)
      end

      request.block.call(results)
    end
  end
end
