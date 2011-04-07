require 'pdf/writer'
require 'pdf/simpletable'

module RailsPDF
  module ControllerExtensions
    attr_accessor :rails_pdf_options

  protected
    def rails_pdf_options
      @rails_pdf_options ||= { 
        :disposition => :inline,
        :filename => nil,
        :writer => { :paper => 'LETTER', :orientation => :portrait }
      }      
    end
    
    def rails_pdf(options={})
      rails_pdf_options.merge! options
    end
  end
  
  module TemplateHandler
  	class Base < ActionView::TemplateHandler
      def rails_pdf_options
        @view.controller.send :rails_pdf_options
      end

      def ie_request?
        @view.request.env['HTTP_USER_AGENT'] =~ /msie/i
      end
 
      def set_pragma
        @view.headers['Pragma'] ||= ie_request? ? 'no-cache' : ''
      end

      def set_cache_control
        @view.headers['Cache-Control'] ||= ie_request? ? 'no-cache, must-revalidate' : ''
      end
 
      def set_content_type
        @view.response.content_type = Mime::PDF
      end
      
      def set_disposition
        disposition = rails_pdf_options[:disposition].to_s
        filename    = rails_pdf_options[:filename] ? "filename=#{rails_pdf_options[:filename]}" : nil
        @view.headers["Content-Disposition"] = [disposition,filename].compact.join(';')
      end
      
      def build_headers
        set_pragma
        set_cache_control
        set_content_type
        set_disposition
      end
      
      def build_source_to_establish_locals(template)
        rails_pdf_locals = {}
        rails_pdf_locals.merge!(template.locals)
        rails_pdf_locals.map {|k,v| "#{k} = #{v};"}.join("")
      end
      
      def render(template)
        build_headers
 
        source = build_source_to_establish_locals(template)
        source += "\n#{template.source}"
 
        pdf = PDF::Writer.new(rails_pdf_options[:writer])
        pdf.compressed = true if RAILS_ENV != 'development'
        @view.instance_eval source, template.filename, 1
        pdf.render
      end            
    end
  end
end
