require "spec_helper"
require "stringio"

describe Source::ShellProfile do

    describe "add_source_directives" do

        def foo
            "/opt/foo"
        end

        def bar
            "/opt/bar"
        end

        it "should add no directives" do
            file = StringIO.new

            rc = Source::ShellProfile.new(file)
            rc.add_source_directives()
            
            expect(file.string).to be_empty
        end

        it "should add a directive" do
            file = StringIO.new

            rc = Source::ShellProfile.new(file)
            rc.add_source_directives(foo)

            expect(file.string).to include(". #{foo}")
        end

        it "should add multiple directives" do
            file = StringIO.new

            rc = Source::ShellProfile.new(file)
            rc.add_source_directives(foo, bar)

            expect(file.string).to include(". #{foo}", ". #{bar}")
        end

        it "should not overwrite existing content" do
            file = StringIO.new
            file.puts "Hello world"

            rc = Source::ShellProfile.new(file)
            rc.add_source_directives(foo)

            expect(file.string).to include(". #{foo}", "Hello world")
        end

        it "should not insert duplicate directives" do
            file = StringIO.new

            rc = Source::ShellProfile.new(file)
            rc.add_source_directives(foo, foo)

            expect(file.string).to include(". #{foo}").once
        end
    end
end