##
# Support functions for parsing shell profiles (.rc, .bashrc, .zshrc and so on).
class ShellProfile

    ##
    # Determine whether the shell profile contains a 'source' directive for the specified shell functions script
    def self.includes_source_directive?(rc, shell_functions_script)
        rc =~ /^[^#]*(source|\.)\s+#{shell_functions_script}(#.*|\s.*|\b)$/
    end
end