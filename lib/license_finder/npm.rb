require 'json'
require 'license_finder/package'

module LicenseFinder
  class NPM

    def self.current_modules
      return @modules if @modules

      output = `npm list --json --long`

      json = JSON(output)

      @modules = json.fetch("dependencies",[]).map do |node_module|
        node_module = node_module[1]

        Package.new(OpenStruct.new(
          :name => node_module.fetch("name", nil),
          :version => node_module.fetch("version", nil),
          :full_gem_path => node_module.fetch("path", nil),
          :license => self.harvest_license(node_module),
          :summary => node_module.fetch("description", nil),
          :description => node_module.fetch("readme", nil)
        ))
      end
    end

    def self.has_package?
      File.exists?(package_path)
    end

    private

    def self.package_path
      Pathname.new('package.json').expand_path
    end

    def self.harvest_license(node_module)
      license = node_module.fetch("licenses", []).first

      if license
        license = license.fetch("type", nil)
      end

      if license.nil?
        license = node_module.fetch("license", nil)

        if license.is_a? Hash
          license = license.fetch("type", nil)
        end
      end

      license
    end
  end
end