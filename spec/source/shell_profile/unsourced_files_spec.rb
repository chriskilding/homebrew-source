require "spec_helper"

describe Source::ShellProfile do

    describe "unsourced_files" do

        def foo
            "/opt/foo"
        end

        def bar
            "/opt/bar"
        end

        it "should work with no files to source" do
            rc = Source::ShellProfile.new()
            expect(rc.unsourced_files()).to be_empty
        end

        it "should report files that are not sourced" do
            rc = Source::ShellProfile.new()
            expect(rc.unsourced_files(foo, bar)).to contain_exactly(foo, bar)
        end

        it "should report files that are not sourced, and ignore those which are" do
            rc = Source::ShellProfile.new([
                "source #{foo}"
            ])
            expect(rc.unsourced_files(foo, bar)).to contain_exactly(bar)
        end

        it "should ignore 'source' statements that it has not been told about" do
            rc = Source::ShellProfile.new([
                "source #{foo}",
                "source #{bar}"
            ])
            expect(rc.unsourced_files(foo)).to be_empty
        end

        it "should ignore unrelated statements in the shell profile" do
            rc = Source::ShellProfile.new([
                "SOME_VAR=123",
                "source #{foo}"
            ])
            expect(rc.unsourced_files(foo)).to be_empty
        end

        it "should work when all files are sourced" do
            rc = Source::ShellProfile.new([
                "source #{foo}",
                "source #{bar}"
            ])
            expect(rc.unsourced_files(foo, bar)).to be_empty
        end
    end
end