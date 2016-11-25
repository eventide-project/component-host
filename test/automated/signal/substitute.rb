require_relative '../automated_init'

context "Signal Substitute" do
  context "No signal handler has been defined" do
    substitute = SubstAttr::Substitute.build ProcessHost::Signal

    context "Signal is simulated" do
      substitute.simulate_signal 'SOME-SIGNAL'

      test "Signal is not trapped" do
        refute substitute do
          trapped?
        end
      end
    end
  end

  context "Signal handler has been defined" do
    handled = false

    substitute = SubstAttr::Substitute.build ProcessHost::Signal
    substitute.trap 'SOME-SIGNAL' do
      handled = true
    end

    context "Signal is simulated" do
      substitute.simulate_signal 'SOME-SIGNAL'

      test "Handler block is invoked" do
        assert handled == true
      end

      context "Trapped predicate, no args" do
        test "True is returned" do
          assert substitute do
            trapped?
          end
        end
      end

      context "Trapped predicate, trapped signal is specified" do
        test "True is returned" do
          assert substitute do
            trapped? 'SOME-SIGNAL'
          end
        end
      end

      context "Trapped predicate, other signal is specified" do
        test "False is returned" do
          refute substitute do
            trapped? 'OTHER-SIGNAL'
          end
        end
      end
    end
  end
end
