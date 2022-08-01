require "spec_helper"
require "tempfile"

describe Source::ShellProfileConverger do

    describe "ensure_source_directives_for" do

        def foo
            "/opt/foo"
        end

        def bar
            "/opt/bar"
        end

        it "should append source directives for unsourced files" do
            file = Tempfile.create

            converger = Source::ShellProfileConverger.new(file.path)
            
            converger.ensure_source_directives_for(foo, bar)

            expect(file.readlines(chomp: true)).to include(". #{foo}", ". #{bar}")
        end

        it "should do nothing when all files are sourced" do
            file = Tempfile.create
            file.write <<~EOS
            . #{foo}
            . #{bar}
            EOS
            file.rewind

            converger = Source::ShellProfileConverger.new(file.path)
            converger.ensure_source_directives_for(foo, bar)        
            
            expect(file.readlines(chomp: true)).to include(". #{foo}", ". #{bar}")
        end
    end
end