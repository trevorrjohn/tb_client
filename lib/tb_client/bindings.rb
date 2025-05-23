# frozen_string_literal: true

require "ffi"

require_relative "shared_lib"
require_relative "types"
require_relative "ffi_struct_converter"
require_relative "version"

module TBClient
  module Bindings
    extend FFI::Library

    typedef TBClient::Types::UINT128, :uint128

    ffi_lib TBClient::SharedLib.path

    Operation = enum(FFI::Type::UINT8, [
      :PULSE, 128,
      :GET_EVENTS, 137,
      :CREATE_ACCOUNTS, 138,
      :CREATE_TRANSFERS, 139,
      :LOOKUP_ACCOUNTS, 140,
      :LOOKUP_TRANSFERS, 141,
      :GET_ACCOUNT_TRANSFERS, 142,
      :GET_ACCOUNT_BALANCES, 143,
      :QUERY_ACCOUNTS, 144,
      :QUERY_TRANSFERS, 145,
    ])

    PacketStatus = enum(FFI::Type::UINT8, [
      :OK, 0,
      :TOO_MUCH_DATA, 1,
      :CLIENT_EVICTED, 2,
      :CLIENT_RELEASE_TOO_LOW, 3,
      :CLIENT_RELEASE_TOO_HIGH, 4,
      :CLIENT_SHUTDOWN, 5,
      :INVALID_OPERATION, 6,
      :INVALID_DATA_SIZE, 7,
    ])

    InitStatus = enum(FFI::Type::UINT32, [
      :SUCCESS, 0,
      :UNEXPECTED, 1,
      :OUT_OF_MEMORY, 2,
      :ADDRESS_INVALID, 3,
      :ADDRESS_LIMIT_EXCEEDED, 4,
      :SYSTEM_RESOURCES, 5,
      :NETWORK_SUBSYSTEM, 6,
    ])

    ClientStatus = enum(FFI::Type::UINT32, [
      :OK, 0,
      :INVALID, 1,
    ])

    LogLevel = enum(FFI::Type::UINT32, [
      :ERR, 0,
      :WARN, 1,
      :INFO, 2,
      :DEBUG, 3,
    ])

    RegisterLogCallbackStatus = enum(FFI::Type::UINT32, [
      :SUCCESS, 0,
      :ALREADY_REGISTERED, 1,
      :NOT_REGISTERED, 2,
    ])

    AccountFlags = bitmask(FFI::Type::UINT16, [
      :LINKED, 1 << 0,
      :DEBITS_MUST_NOT_EXCEED_CREDITS, 1 << 1,
      :CREDITS_MUST_NOT_EXCEED_DEBITS, 1 << 2,
      :HISTORY, 1 << 3,
      :IMPORTED, 1 << 4,
      :CLOSED, 1 << 5,
    ])

    TransferFlags = bitmask(FFI::Type::UINT16, [
      :LINKED, 1 << 0,
      :PENDING, 1 << 1,
      :POST_PENDING_TRANSFER, 1 << 2,
      :VOID_PENDING_TRANSFER, 1 << 3,
      :BALANCING_DEBIT, 1 << 4,
      :BALANCING_CREDIT, 1 << 5,
      :CLOSING_DEBIT, 1 << 6,
      :CLOSING_CREDIT, 1 << 7,
      :IMPORTED, 1 << 8,
    ])

    AccountFilterFlags = bitmask(FFI::Type::UINT32, [
      :DEBITS, 1 << 0,
      :CREDITS, 1 << 1,
      :REVERSED, 1 << 2,
    ])

    QueryFilterFlags = bitmask(FFI::Type::UINT32, [
      :REVERSED, 1 << 0,
    ])

    CreateAccountResult = enum(FFI::Type::UINT32, [
      :OK, 0,
      :LINKED_EVENT_FAILED, 1,
      :LINKED_EVENT_CHAIN_OPEN, 2,
      :IMPORTED_EVENT_EXPECTED, 22,
      :IMPORTED_EVENT_NOT_EXPECTED, 23,
      :TIMESTAMP_MUST_BE_ZERO, 3,
      :IMPORTED_EVENT_TIMESTAMP_OUT_OF_RANGE, 24,
      :IMPORTED_EVENT_TIMESTAMP_MUST_NOT_ADVANCE, 25,
      :RESERVED_FIELD, 4,
      :RESERVED_FLAG, 5,
      :ID_MUST_NOT_BE_ZERO, 6,
      :ID_MUST_NOT_BE_INT_MAX, 7,
      :EXISTS_WITH_DIFFERENT_FLAGS, 15,
      :EXISTS_WITH_DIFFERENT_USER_DATA_128, 16,
      :EXISTS_WITH_DIFFERENT_USER_DATA_64, 17,
      :EXISTS_WITH_DIFFERENT_USER_DATA_32, 18,
      :EXISTS_WITH_DIFFERENT_LEDGER, 19,
      :EXISTS_WITH_DIFFERENT_CODE, 20,
      :EXISTS, 21,
      :FLAGS_ARE_MUTUALLY_EXCLUSIVE, 8,
      :DEBITS_PENDING_MUST_BE_ZERO, 9,
      :DEBITS_POSTED_MUST_BE_ZERO, 10,
      :CREDITS_PENDING_MUST_BE_ZERO, 11,
      :CREDITS_POSTED_MUST_BE_ZERO, 12,
      :LEDGER_MUST_NOT_BE_ZERO, 13,
      :CODE_MUST_NOT_BE_ZERO, 14,
      :IMPORTED_EVENT_TIMESTAMP_MUST_NOT_REGRESS, 26,
    ])

    CreateTransferResult = enum(FFI::Type::UINT32, [
      :OK, 0,
      :LINKED_EVENT_FAILED, 1,
      :LINKED_EVENT_CHAIN_OPEN, 2,
      :IMPORTED_EVENT_EXPECTED, 56,
      :IMPORTED_EVENT_NOT_EXPECTED, 57,
      :TIMESTAMP_MUST_BE_ZERO, 3,
      :IMPORTED_EVENT_TIMESTAMP_OUT_OF_RANGE, 58,
      :IMPORTED_EVENT_TIMESTAMP_MUST_NOT_ADVANCE, 59,
      :RESERVED_FLAG, 4,
      :ID_MUST_NOT_BE_ZERO, 5,
      :ID_MUST_NOT_BE_INT_MAX, 6,
      :EXISTS_WITH_DIFFERENT_FLAGS, 36,
      :EXISTS_WITH_DIFFERENT_PENDING_ID, 40,
      :EXISTS_WITH_DIFFERENT_TIMEOUT, 44,
      :EXISTS_WITH_DIFFERENT_DEBIT_ACCOUNT_ID, 37,
      :EXISTS_WITH_DIFFERENT_CREDIT_ACCOUNT_ID, 38,
      :EXISTS_WITH_DIFFERENT_AMOUNT, 39,
      :EXISTS_WITH_DIFFERENT_USER_DATA_128, 41,
      :EXISTS_WITH_DIFFERENT_USER_DATA_64, 42,
      :EXISTS_WITH_DIFFERENT_USER_DATA_32, 43,
      :EXISTS_WITH_DIFFERENT_LEDGER, 67,
      :EXISTS_WITH_DIFFERENT_CODE, 45,
      :EXISTS, 46,
      :ID_ALREADY_FAILED, 68,
      :FLAGS_ARE_MUTUALLY_EXCLUSIVE, 7,
      :DEBIT_ACCOUNT_ID_MUST_NOT_BE_ZERO, 8,
      :DEBIT_ACCOUNT_ID_MUST_NOT_BE_INT_MAX, 9,
      :CREDIT_ACCOUNT_ID_MUST_NOT_BE_ZERO, 10,
      :CREDIT_ACCOUNT_ID_MUST_NOT_BE_INT_MAX, 11,
      :ACCOUNTS_MUST_BE_DIFFERENT, 12,
      :PENDING_ID_MUST_BE_ZERO, 13,
      :PENDING_ID_MUST_NOT_BE_ZERO, 14,
      :PENDING_ID_MUST_NOT_BE_INT_MAX, 15,
      :PENDING_ID_MUST_BE_DIFFERENT, 16,
      :TIMEOUT_RESERVED_FOR_PENDING_TRANSFER, 17,
      :CLOSING_TRANSFER_MUST_BE_PENDING, 64,
      :LEDGER_MUST_NOT_BE_ZERO, 19,
      :CODE_MUST_NOT_BE_ZERO, 20,
      :DEBIT_ACCOUNT_NOT_FOUND, 21,
      :CREDIT_ACCOUNT_NOT_FOUND, 22,
      :ACCOUNTS_MUST_HAVE_THE_SAME_LEDGER, 23,
      :TRANSFER_MUST_HAVE_THE_SAME_LEDGER_AS_ACCOUNTS, 24,
      :PENDING_TRANSFER_NOT_FOUND, 25,
      :PENDING_TRANSFER_NOT_PENDING, 26,
      :PENDING_TRANSFER_HAS_DIFFERENT_DEBIT_ACCOUNT_ID, 27,
      :PENDING_TRANSFER_HAS_DIFFERENT_CREDIT_ACCOUNT_ID, 28,
      :PENDING_TRANSFER_HAS_DIFFERENT_LEDGER, 29,
      :PENDING_TRANSFER_HAS_DIFFERENT_CODE, 30,
      :EXCEEDS_PENDING_TRANSFER_AMOUNT, 31,
      :PENDING_TRANSFER_HAS_DIFFERENT_AMOUNT, 32,
      :PENDING_TRANSFER_ALREADY_POSTED, 33,
      :PENDING_TRANSFER_ALREADY_VOIDED, 34,
      :PENDING_TRANSFER_EXPIRED, 35,
      :IMPORTED_EVENT_TIMESTAMP_MUST_NOT_REGRESS, 60,
      :IMPORTED_EVENT_TIMESTAMP_MUST_POSTDATE_DEBIT_ACCOUNT, 61,
      :IMPORTED_EVENT_TIMESTAMP_MUST_POSTDATE_CREDIT_ACCOUNT, 62,
      :IMPORTED_EVENT_TIMEOUT_MUST_BE_ZERO, 63,
      :DEBIT_ACCOUNT_ALREADY_CLOSED, 65,
      :CREDIT_ACCOUNT_ALREADY_CLOSED, 66,
      :OVERFLOWS_DEBITS_PENDING, 47,
      :OVERFLOWS_CREDITS_PENDING, 48,
      :OVERFLOWS_DEBITS_POSTED, 49,
      :OVERFLOWS_CREDITS_POSTED, 50,
      :OVERFLOWS_DEBITS, 51,
      :OVERFLOWS_CREDITS, 52,
      :OVERFLOWS_TIMEOUT, 53,
      :EXCEEDS_CREDITS, 54,
      :EXCEEDS_DEBITS, 55,
    ])

    class Packet < FFI::Struct
      include FFIStructConverter

      layout(
        user_data: :pointer,
        data: :pointer,
        data_size: :uint32,
        user_tag: :uint16,
        operation: :uint8,
        status: PacketStatus,
        opaque: [:uint8, 32],
      )
    end

    class Client < FFI::Struct
      include FFIStructConverter

      layout(
        opaque: [:uint64, 4],
      )
    end

    class Account < FFI::Struct
      include FFIStructConverter

      layout(
        id: :uint128,
        debits_pending: :uint128,
        debits_posted: :uint128,
        credits_pending: :uint128,
        credits_posted: :uint128,
        user_data_128: :uint128,
        user_data_64: :uint64,
        user_data_32: :uint32,
        reserved: :uint32,
        ledger: :uint32,
        code: :uint16,
        flags: AccountFlags,
        timestamp: :uint64,
      )
    end

    class Transfer < FFI::Struct
      include FFIStructConverter

      layout(
        id: :uint128,
        debit_account_id: :uint128,
        credit_account_id: :uint128,
        amount: :uint128,
        pending_id: :uint128,
        user_data_128: :uint128,
        user_data_64: :uint64,
        user_data_32: :uint32,
        timeout: :uint32,
        ledger: :uint32,
        code: :uint16,
        flags: TransferFlags,
        timestamp: :uint64,
      )
    end

    class CreateAccountsResult < FFI::Struct
      include FFIStructConverter

      layout(
        index: :uint32,
        result: CreateAccountResult,
      )
    end

    class CreateTransfersResult < FFI::Struct
      include FFIStructConverter

      layout(
        index: :uint32,
        result: CreateTransferResult,
      )
    end

    class AccountFilter < FFI::Struct
      include FFIStructConverter

      layout(
        account_id: :uint128,
        user_data_128: :uint128,
        user_data_64: :uint64,
        user_data_32: :uint32,
        code: :uint16,
        reserved: [:uint8, 58],
        timestamp_min: :uint64,
        timestamp_max: :uint64,
        limit: :uint32,
        flags: AccountFilterFlags,
      )
    end

    class AccountBalance < FFI::Struct
      include FFIStructConverter

      layout(
        debits_pending: :uint128,
        debits_posted: :uint128,
        credits_pending: :uint128,
        credits_posted: :uint128,
        timestamp: :uint64,
        reserved: [:uint8, 56],
      )
    end

    class QueryFilter < FFI::Struct
      include FFIStructConverter

      layout(
        user_data_128: :uint128,
        user_data_64: :uint64,
        user_data_32: :uint32,
        ledger: :uint32,
        code: :uint16,
        reserved: [:uint8, 6],
        timestamp_min: :uint64,
        timestamp_max: :uint64,
        limit: :uint32,
        flags: QueryFilterFlags,
      )
    end

    # [client_id, packet, timestamp, result_}ptr, result_len]
    callback :init_completion, [:uint, Packet.by_ref, :uint64, :pointer, :uint32], :void
    callback :init_echo_completion, [:uint, Packet.by_ref, :uint64, :pointer, :uint32], :void
    callback :log_handler, [LogLevel, :pointer, :uint32], :void

    attach_function :tb_client_init, [Client.by_ref, :pointer, :string, :uint32, :uint, :init_completion], InitStatus
    attach_function :tb_client_init_echo, [Client.by_ref, :pointer, :string, :uint32, :uint, :init_echo_completion], InitStatus
    attach_function :tb_client_completion_context, [Client.by_ref, :pointer], ClientStatus
    attach_function :tb_client_submit, [Client.by_ref, Packet.by_ref], ClientStatus
    attach_function :tb_client_deinit, [Client.by_ref], ClientStatus
    attach_function :tb_client_register_log_callback, [:log_handler, :bool], RegisterLogCallbackStatus
  end
end
