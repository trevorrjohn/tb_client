require 'ffi'
require_relative "ffi_struct_converter"

module TBClient
  module Types
    class UINT128 < FFI::Struct
      include FFIStructConverter

      layout(low: :uint64, high: :uint64)

      class << self
        def to_native(value, _ctx)
          case value
          when UINT128
            value.pointer
          when Integer
            obj = self.new
            obj[:low] = value & 0xFFFFFFFFFFFFFFFF
            obj[:high] = (value >> 64) & 0xFFFFFFFFFFFFFFFF
            obj.pointer
          when FFI::Pointer, FFI::MemoryPointer
            self.new(value).pointer
          else
            raise TypeError, "can't convert #{value.class} to UINT128"
          end
        end

        def from_native(value, _ctx)
          if value.is_a?(self)
            value
          else
            obj = self.new
            ptr = FFI::Pointer.new(value)
            obj[:low] = ptr.read_uint64(0)
            obj[:high] = ptr.read_uint64(8)
            obj
          end
        end

        def native_type
          @native_type ||= FFI::Type::Mapped.new(FFI::Type::ARRAY.new(FFI::Type::UINT64, 2))
        end
      end

      def to_i
        self[:high].to_i << 64 | self[:low].to_i
      end

      def to_s
        to_i.to_s
      end
    end
  end
end
