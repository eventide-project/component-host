require_relative '../automated_init'

context "Signal" do
  context "Substitute" do
    context "No signal handler has been defined" do
      substitute = Dependency::Substitute.build ComponentHost::Signal

      context "Signal is Sent" do
        substitute.send 'SOME-SIGNAL'

        test "Signal is not trapped" do
          refute substitute do
            trapped?
          end
        end
      end
    end

    context "Signal handler has been defined" do
      handled = false

      substitute = Dependency::Substitute.build ComponentHost::Signal
      substitute.trap 'SOME-SIGNAL' do
        handled = true
      end

      context "Signal is Sent" do
        substitute.send 'SOME-SIGNAL'

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
end
