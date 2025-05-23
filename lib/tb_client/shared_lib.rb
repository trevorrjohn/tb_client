module TBClient
  module SharedLib
    class << self
      EXT_DIR = '../../ext'.freeze

      def path
        prefix = ''
        linux_libc = ''
        suffix = ''

        arch, os = RUBY_PLATFORM.split('-')

        arch =
          case arch
          when 'x86_64', 'amd64' then 'x86_64'
          when 'aarch64', 'arm64' then 'aarch64'
          else
            raise "Unsupported architecture: #{arch}"
          end

        case os
        when /darwin/
          prefix = 'lib'
          system = 'macos'
          suffix = '.dylib'
        when 'linux'
          prefix = 'lib'
          system = 'linux'
          linux_libc = detect_libc
          suffix = '.so'
        when 'windows'
          system = 'windows'
          suffix = '.dll'
        else
          raise "Unsupported system: #{os}"
        end

        File.expand_path(
          "#{EXT_DIR}/#{arch}-#{system}#{linux_libc}/#{prefix}tb_client#{suffix}",
          __dir__
        )
      end

      private

      def detect_libc
        ldd_output = `ldd --version 2>&1 | head -n 1`.downcase

        if ldd_output.include?('musl')
          '-musl'
        elsif ldd_output.include?('gnu') || ldd_output.include?('glibc')
          '-gnu.2.27'
        else
          raise "Unsupported libc: #{ldd_output}"
        end
      end
    end

    def validate_uint!(name, bits, value)
      if value > 2**bits - 1
        raise ArgumentError, "#{name} == #{value} is too large to fit in #{bits} bits"
      elsif value < 0
        raise ArgumentError, "#{name} == #{value} cannot be negative"
      end
    end
  end
end
