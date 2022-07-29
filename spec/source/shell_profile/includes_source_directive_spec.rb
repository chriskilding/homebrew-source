require "spec_helper"
require "rspec/expectations"

RSpec::Matchers.define :include_source_directive_for do |expected|
    match do |actual|
        # expected = the path to source
        # actual = the rc file
        Source::ShellProfile.includes_source_directive?(actual, expected)
    end
    failure_message do |actual|
        "expected that the rc file '#{actual}' would include a source directive for '#{expected}', but it did not"
    end
end

RSpec::Matchers.define :exclude_source_directive_for do |expected|
    match do |actual|
        # expected = the path to source
        # actual = the rc file
        !Source::ShellProfile.includes_source_directive?(actual, expected)
    end
    failure_message do |actual|
        "expected that the rc file '#{actual}' would NOT include a source directive for '#{expected}', but it did"
    end
end

describe Source::ShellProfile do

    describe "includes_source_directive" do

        # the path that should be 'source'd in the rc file
        def path
            "/opt/foo"
        end

        it "should allow 'source' syntax" do
            expect("source #{path}").to include_source_directive_for(path)
        end

        it "should allow 'dot' syntax" do
            expect(". #{path}").to include_source_directive_for(path)
        end

        context "with whitespace" do
            it "should allow leading whitespace" do
                expect("  source #{path}").to include_source_directive_for(path)
            end

            it "should allow whitespace between <source> and <path>" do
                expect("source   #{path}").to include_source_directive_for(path)
            end

            it "should allow trailing whitespace" do
                expect("source #{path}  ").to include_source_directive_for(path)
            end
        end

        context "with comments" do
            it "should allow trailing comments" do
                expect("source #{path} # a comment").to include_source_directive_for(path)
            end

            it "should not match when commented out" do
                expect("# source #{path}").to exclude_source_directive_for(path)
            end
        end

        it "should not allow similar paths" do
            expect("source #{path}-bar").to exclude_source_directive_for(path)
        end

        it "should not allow longer paths" do
            expect("source #{path}bar").to exclude_source_directive_for(path)
        end

        context "with ordering" do
            it "should allow being the first statement" do
                expect("source #{path} && something").to include_source_directive_for(path)
            end

            it "should allow being the middle statement" do
                expect("something && source #{path} && other").to include_source_directive_for(path)
            end

            it "should allow being the last statement" do
                expect("something && source #{path}").to include_source_directive_for(path)
            end
        end
    end
end