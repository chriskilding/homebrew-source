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
            Tempfile.open("abc") do |file|
                converger = Source::ShellProfileConverger.new(file)
                
                converger.ensure_source_directives_for(foo, bar)

                expect(file.readlines(chomp: true)).to include(". #{foo}", ". #{bar}")
            end
        end

        it "should do nothing when all files are sourced" do
            Tempfile.open("def") do |file|
                file.write <<~EOS
                . #{foo}
                . #{bar}
                EOS
                file.rewind

                converger = Source::ShellProfileConverger.new(file)
                converger.ensure_source_directives_for(foo, bar)        
                
                expect(file.readlines(chomp: true)).to include(". #{foo}", ". #{bar}")
            end
        end
    end
end