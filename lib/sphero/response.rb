class Sphero
  class Response
    SOP1 = 0
    SOP2 = 1
    MRSP = 2
    SEQ  = 3
    DLEN = 4

    CODE_OK = 0

    def initialize header, body
      @header = header
      @body   = body
    end

    def empty?
      @header[DLEN] == 1
    end

    def success?
      @header[MRSP] == CODE_OK
    end

    def seq
      @header[SEQ]
    end

    def body
      @body.unpack 'C*'
    end

    class GetAutoReconnect < Response
      def time
        body[1]
      end
    end

    class GetPowerState < Response
      # constants for power_state
      CHARGING = 0x01
      OK       = 0x02
      LOW      = 0x03
      CRITICAL = 0x04

      def body
        @body.unpack 'CCnnnC'
      end

      def rec_ver
        body[0]
      end

      def power_state
        body[1]
      end

      # Voltage * 100
      def batt_voltage
        body[2]
      end

      def num_charges
        body[3]
      end

      # Time since awakened in seconds
      def time_since_charge
        body[4]
      end
    end

    class GetBluetoothInfo < Response
      def name
        body.take(16).slice_before(0x00).first.pack 'C*'
      end

      def bta
        body.drop(16).slice_before(0x00).first.pack 'C*'
      end
    end

    class GetRGB < Response
      def r; body[0]; end
      def g; body[1]; end
      def b; body[2]; end
    end

    class GetPermanentOptionFlags < Response
      SLEEP_ON_CHARGE              = 0x01 # bit 0
      VECTOR_DRIVE                 = 0x02 # bit 1
      DISABLE_SELF_LEVEL_ON_CHARGE = 0x04 # bit 2
      TAIL_LIGHT_ALWAYS_ON         = 0x08 # bit 3
      MOTION_TIMEOUTS              = 0x10 # bit 4
      RETAIL_DEMO_MODE             = 0x20 # bit 6

      def inspect
        <<-EOS
        Sleep on charge: #{sleep_on_charge?}
        Vector drive: #{vector_drive?}
        Self level on charge: #{self_level_on_charge?}
        Tail light always on: #{tail_light?}
        Motion timeouts: #{motion_timeouts?}
        Retail demo mode: #{retail_demo_mode?}
        EOS
      end

      def body
        @body.unpack 'N'
      end

      def flags
        body.first
      end

      def sleep_on_charge?; on? SLEEP_ON_CHARGE end
      def vector_drive?; on? VECTOR_DRIVE end
      def self_level_on_charge?; !(on? DISABLE_SELF_LEVEL_ON_CHARGE) end
      def tail_light?; on? TAIL_LIGHT_ALWAYS_ON end
      def motion_timeouts?; on? MOTION_TIMEOUTS end
      def retail_demo_mode?; on? RETAIL_DEMO_MODE end

      protected

      def on?(mask)
        (flags & mask) == mask
      end

      def off?(mask)
        (flags & mask) == 0
      end
    end
  end
end
