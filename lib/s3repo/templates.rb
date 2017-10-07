require 'erb'

module S3Repo
  ##
  # Templates object, represents the generated templates for repo navigation
  class Templates < Base
    def initialize(params = {})
      super
    end

    def update!
      templates.each do |filename, template|
        rendered = template.render(template_binding.binding)
        client.upload(filename, rendered)
      end
    end

    private

    def metadata
      @options[:metadata] ||= Metadata.new(@options)
    end

    def template_binding
      @template_binding ||= TemplateBinding.new(
        @options[:template_params].merge(packages: metadata.packages)
      )
    end

    def templates
      @templates ||= template_files.map do |x|
        [File.basename(x), ERB.new(File.read(x))]
      end
    end

    def template_files
      @template_files ||= Dir.glob(template_path + '/*')
    end

    def template_path
      @template_path ||= @options[:template_dir] || raise('No template dir')
    end
  end

  ##
  # Binding object to sandbox template vars
  class TemplateBinding
    def initialize(params = {})
      params.each { |key, val| instance_variable_set(":@#{key}", val) }
    end

    def binding
      binding
    end
  end
end
