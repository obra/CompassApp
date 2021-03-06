require 'singleton'

class PreferencePanel
  include Singleton

  def initialize()
    @display = Swt::Widgets::Display.get_current
  end

  def open
    self.create_window if !@shell || @shell.isDisposed
    m=@display.getPrimaryMonitor().getBounds()
    rect = @shell.getClientArea()
    @shell.setLocation((m.width-rect.width) /2, (m.height-rect.height) /2) 
    @shell.open
    @shell.forceActive
  end

  def create_window
    @shell = Swt::Widgets::Shell.new(@display, Swt::SWT::DIALOG_TRIM)
    @shell.setText("Preference")
    @shell.setBackgroundMode(Swt::SWT::INHERIT_DEFAULT)
    @shell.setSize(550,300)
    @shell.layout = Swt::Layout::FillLayout.new

    @tabFolder = Swt::Widgets::TabFolder.new(@shell, Swt::SWT::BORDER);

    compass_version_tab = Swt::Widgets::TabItem.new( @tabFolder, Swt::SWT::NONE)
    compass_version_tab.setControl( self.compass_version_composite );
    compass_version_tab.setText('Compass')

    notification_tab = Swt::Widgets::TabItem.new( @tabFolder, Swt::SWT::NONE)
    notification_tab.setControl( self.notification_composite );
    notification_tab.setText('Notification')

    http_server_tab = Swt::Widgets::TabItem.new( @tabFolder, Swt::SWT::NONE)
    http_server_tab.setControl( self.services_composite );
    http_server_tab.setText('Services')

    @shell.pack
  end

  def services_composite
    composite =Swt::Widgets::Composite.new(@tabFolder, Swt::SWT::NO_MERGE_PAINTS );
    layout = Swt::Layout::FormLayout.new
    layout.marginWidth = layout.marginHeight = 10
    layout.spacing = 0
    composite.layout = layout
    
    # ====== web server =====
    @service_http_button = Swt::Widgets::Button.new(composite, Swt::SWT::CHECK )
    @service_http_button.setText( 'Enable Web Server' )
    @service_http_button.setSelection( App::CONFIG["services"].include? :http )
    @service_http_button.addListener(Swt::SWT::Selection, services_button_handler)

    layoutdata = Swt::Layout::FormData.new()
    layoutdata.left = Swt::Layout::FormAttachment.new( @service_http_button, 10, Swt::SWT::LEFT )
    layoutdata.top  = Swt::Layout::FormAttachment.new( @service_http_button, 10, Swt::SWT::BOTTOM)
    http_port_label = Swt::Widgets::Label.new( composite, Swt::SWT::LEFT | Swt::SWT::WRAP)
    http_port_label.setText("http://127.0.0.1:")
    http_port_label.setLayoutData(layoutdata)


    layoutdata = Swt::Layout::FormData.new(50, Swt::SWT::DEFAULT)
    layoutdata.left = Swt::Layout::FormAttachment.new( http_port_label, 1, Swt::SWT::RIGHT)
    layoutdata.top  = Swt::Layout::FormAttachment.new( http_port_label, 0, Swt::SWT::CENTER)
    @http_port_text  = Swt::Widgets::Text.new(composite, Swt::SWT::BORDER)
    @http_port_text.setText( App::CONFIG["services_http_port"].to_s )
    @http_port_text.setLayoutData( layoutdata )
    @http_port_text.addListener(Swt::SWT::Modify, services_port_handler)

    layoutdata = Swt::Layout::FormData.new(480, Swt::SWT::DEFAULT)
    layoutdata.left = Swt::Layout::FormAttachment.new( http_port_label, 0, Swt::SWT::LEFT )
    layoutdata.top  = Swt::Layout::FormAttachment.new( http_port_label, 10, Swt::SWT::BOTTOM)
    http_service_info = Swt::Widgets::Label.new( composite, Swt::SWT::LEFT | Swt::SWT::WRAP)
    http_service_info.setText("It will run a tiny web server when you watch a folder, so you can use absolute path in your files.")
    http_service_info.setLayoutData(layoutdata)

    # ====== livereload server =====
    layoutdata = Swt::Layout::FormData.new()
    layoutdata.left = Swt::Layout::FormAttachment.new( @service_http_button, 0, Swt::SWT::LEFT )
    layoutdata.top  = Swt::Layout::FormAttachment.new( http_service_info, 10, Swt::SWT::BOTTOM)
    @service_livereload_button = Swt::Widgets::Button.new(composite, Swt::SWT::CHECK )
    @service_livereload_button.setText( 'Enable livereload' )
    @service_livereload_button.setSelection( App::CONFIG["services"].include? :livereload )
    @service_livereload_button.addListener(Swt::SWT::Selection, services_button_handler)
    @service_livereload_button.setLayoutData(layoutdata)

    layoutdata = Swt::Layout::FormData.new()
    layoutdata.left = Swt::Layout::FormAttachment.new( @service_livereload_button, 10, Swt::SWT::LEFT )
    layoutdata.top  = Swt::Layout::FormAttachment.new( @service_livereload_button, 10, Swt::SWT::BOTTOM)
    livereload_port_label = Swt::Widgets::Label.new( composite, Swt::SWT::LEFT | Swt::SWT::WRAP)
    livereload_port_label.setText("Port")
    livereload_port_label.setLayoutData(layoutdata)


    layoutdata = Swt::Layout::FormData.new(50, Swt::SWT::DEFAULT)
    layoutdata.left = Swt::Layout::FormAttachment.new( livereload_port_label, 3, Swt::SWT::RIGHT)
    layoutdata.top = Swt::Layout::FormAttachment.new(  livereload_port_label, 0, Swt::SWT::CENTER)
    @livereload_port_text = Swt::Widgets::Text.new(composite, Swt::SWT::BORDER)
    @livereload_port_text.setText( App::CONFIG["services_livereload_port"].to_s )
    @livereload_port_text.setLayoutData( layoutdata )
    @livereload_port_text.addListener(Swt::SWT::Modify, services_port_handler)
    
    layoutdata = Swt::Layout::FormData.new(480, Swt::SWT::DEFAULT)
    layoutdata.left = Swt::Layout::FormAttachment.new( livereload_port_label, 0, Swt::SWT::LEFT )
    layoutdata.top  = Swt::Layout::FormAttachment.new( livereload_port_label, 10, Swt::SWT::BOTTOM)
    livereload_service_info = Swt::Widgets::Link.new( composite, Swt::SWT::LEFT | Swt::SWT::WRAP)
    livereload_service_info.setText("<a href=\"https://github.com/mockko/livereload\">livereload</a> applies CSS/JS Changes to browsers without reloading the page, and auto reloads the page when HTML changes")
    livereload_service_info.setLayoutData(layoutdata)
    livereload_service_info.addListener(Swt::SWT::Selection, Swt::Widgets::Listener.impl do |method, evt| 
       Swt::Program.launch(evt.text)
    end)
    
    layoutdata = Swt::Layout::FormData.new(480, Swt::SWT::DEFAULT)
    layoutdata.left = Swt::Layout::FormAttachment.new( livereload_service_info, 0, Swt::SWT::LEFT )
    layoutdata.top  = Swt::Layout::FormAttachment.new( livereload_service_info, 00, Swt::SWT::BOTTOM)
    livereload_service_help_info = Swt::Widgets::Link.new( composite, Swt::SWT::LEFT | Swt::SWT::WRAP)
    livereload_service_help_info.setText("You have to install <a href=\"https://github.com/handlino/CompassApp/wiki/livereload-browser-extension\">livereload browser extension</a> to use this feature.")
    livereload_service_help_info.setLayoutData(layoutdata)
    livereload_service_help_info.addListener(Swt::SWT::Selection, Swt::Widgets::Listener.impl do |method, evt| 
       Swt::Program.launch(evt.text)
    end)
     return composite
  end

  def services_button_handler 
    Swt::Widgets::Listener.impl do |method, evt|   
      App::CONFIG["services"] = []
      App::CONFIG["services"] << :http if @service_http_button.getSelection       
      App::CONFIG["services"] << :livereload if @service_livereload_button.getSelection       
      App.save_config
      Tray.instance.rewatch
    end
  end

  def services_port_handler 
    Swt::Widgets::Listener.impl do |method, evt|   
      has_change = false
      port = @http_port_text.getText.to_i
      port = port.to_i > 0 ? port.to_i : App::CONFIG['services_http_port']
      if App::CONFIG['services_http_port'] != port
        App::CONFIG['services_http_port'] = port
        @http_port_text.setText(App::CONFIG['services_http_port'].to_s)
        has_change = true 
      end
      
      port = @livereload_port_text.getText.to_i
      port = port.to_i > 0 ? port.to_i : App::CONFIG['services_livereload_port']
      if App::CONFIG['services_livereload_port'] != port
        App::CONFIG['services_livereload_port'] = port
        @livereload_port_text.setText(App::CONFIG['services_livereload_port'].to_s)
        has_change = true 
      end

      if has_change
        App.save_config
        Tray.instance.rewatch
      end
    end
  end

  def notification_composite
    composite =Swt::Widgets::Composite.new(@tabFolder, Swt::SWT::NO_MERGE_PAINTS );
    layout = Swt::Layout::FormLayout.new
    layout.marginWidth = layout.marginHeight = 10
    layout.spacing = 0
    composite.layout = layout

    label = Swt::Widgets::Label.new( composite, Swt::SWT::LEFT | Swt::SWT::WRAP)
    label.setText('Notification Types')

    layoutdata = Swt::Layout::FormData.new()
    layoutdata.left = Swt::Layout::FormAttachment.new( label, 10, Swt::SWT::LEFT)
    layoutdata.top = Swt::Layout::FormAttachment.new( label,  5, Swt::SWT::BOTTOM)
    button_group =Swt::Widgets::Composite.new( composite, Swt::SWT::NO_MERGE_PAINTS );
    button_group.setLayoutData( layoutdata )
    layout = Swt::Layout::RowLayout.new(Swt::SWT::VERTICAL) 
    layout.spacing = 10
    button_group.setLayout( layout );

    @notification_error_button = Swt::Widgets::Button.new(button_group, Swt::SWT::CHECK )
    @notification_error_button.setText( 'Errors and Warnings' )
    @notification_error_button.setSelection( App::CONFIG["notifications"].include?( :error ) )
    @notification_error_button.addListener( Swt::SWT::Selection, notification_button_handler )

    @notification_change_button = Swt::Widgets::Button.new(button_group, Swt::SWT::CHECK )
    @notification_change_button.setText( 'Other Change ( create, update, ...)' )
    @notification_change_button.setSelection(App::CONFIG["notifications"].include?( :directory ))
    @notification_change_button.addListener(Swt::SWT::Selection, notification_button_handler)


    layoutdata = Swt::Layout::FormData.new(480,Swt::SWT::DEFAULT)
    layoutdata.left = Swt::Layout::FormAttachment.new( label, 0, Swt::SWT::LEFT)
    layoutdata.top = Swt::Layout::FormAttachment.new( button_group,  20, Swt::SWT::BOTTOM)
    label = Swt::Widgets::Label.new( composite, Swt::SWT::LEFT | Swt::SWT::WRAP)
    label.setText('Log File')
    label.setLayoutData(layoutdata)
    layoutdata = Swt::Layout::FormData.new(480,Swt::SWT::DEFAULT)
    layoutdata.left = Swt::Layout::FormAttachment.new( label, 14, Swt::SWT::LEFT)
    layoutdata.top = Swt::Layout::FormAttachment.new(  label,  5, Swt::SWT::BOTTOM)
    @log_notifaction_button = Swt::Widgets::Button.new(composite, Swt::SWT::CHECK )
    @log_notifaction_button.setLayoutData( layoutdata )
    @log_notifaction_button.setText( "Generate compass_app_log.txt in the project folder" )
    @log_notifaction_button.setSelection( App::CONFIG["save_notification_to_file"] )
    @log_notifaction_button.addListener(Swt::SWT::Selection, notification_button_handler)


    return  composite
  end

  def notification_button_handler 
    Swt::Widgets::Listener.impl do |method, evt|   
      notifications = []
      if @notification_error_button.getSelection 
        notifications += [ :error, :warnings ]
      end
      if @notification_change_button.getSelection 
        notifications += [ :directory, :remove, :create, :overwrite, :compile, :identical ]
      end
      App::CONFIG["notifications"] = notifications
      App::CONFIG['save_notification_to_file'] = @log_notifaction_button.getSelection
      App.save_config

    end
  end

  def compass_version_composite()
    composite =Swt::Widgets::Composite.new(@tabFolder, Swt::SWT::NO_MERGE_PAINTS );
    layout = Swt::Layout::FormLayout.new
    layout.marginWidth = layout.marginHeight = 10
    layout.spacing = 0
    composite.layout = layout

    button_group =Swt::Widgets::Composite.new(composite, Swt::SWT::NO_MERGE_PAINTS );
    rowlayout = Swt::Layout::RowLayout.new(Swt::SWT::VERTICAL) 
    rowlayout.marginBottom = 0;
    rowlayout.spacing = 0;
    button_group.setLayout( rowlayout );

    @button_v11 = Swt::Widgets::Button.new(button_group, Swt::SWT::RADIO )
    @button_v11.setText("Sass 3.1.1 + Compass 0.11.1 (default)")
    @button_v11.setSelection( App::CONFIG['use_version'] == 0.11 || !(App::CONFIG['use_specify_gem_path'] || App::CONFIG['use_version']) )
    @button_v11.addListener(Swt::SWT::Selection, compass_version_button_handler)

    @button_v10 = Swt::Widgets::Button.new(button_group, Swt::SWT::RADIO )
    @button_v10.setText("Sass 3.0.24 + Compass 0.10.6 (older syntax)")
    @button_v10.setSelection( App::CONFIG['use_version'] == 0.10 )
    @button_v10.addListener(Swt::SWT::Selection, compass_version_button_handler)


    @use_specify_gem_path_btn = Swt::Widgets::Button.new(button_group, Swt::SWT::RADIO )
    @use_specify_gem_path_btn.setText("Use specific gem path")
    @use_specify_gem_path_btn.setSelection(App::CONFIG['use_specify_gem_path'])
    @use_specify_gem_path_btn.addListener(Swt::SWT::Selection, compass_version_button_handler)


    data = Swt::Layout::FormData.new(480,Swt::SWT::DEFAULT)
    data.left = Swt::Layout::FormAttachment.new( button_group, 22, Swt::SWT::LEFT)
    data.top = Swt::Layout::FormAttachment.new( button_group, 0, Swt::SWT::BOTTOM)
    special_gem_label = Swt::Widgets::Label.new( composite, Swt::SWT::LEFT | Swt::SWT::WRAP)
    special_gem_label.setText("If you want use RubyGems to manage extensions, you can specify your own gem path.")
    special_gem_label.setLayoutData(data)

    data = Swt::Layout::FormData.new(480,Swt::SWT::DEFAULT)
    data.left = Swt::Layout::FormAttachment.new( special_gem_label, 1, Swt::SWT::LEFT)
    data.top = Swt::Layout::FormAttachment.new( special_gem_label, 4, Swt::SWT::BOTTOM)
    special_gem_label_ex = Swt::Widgets::Label.new( composite, Swt::SWT::LEFT | Swt::SWT::WRAP)
    special_gem_label_ex.setText("ex, /usr/local/lib/ruby/gems/1.8:/Users/foo/.gems")
    special_gem_label_ex.setLayoutData(data)


    layoutdata = Swt::Layout::FormData.new(480, Swt::SWT::DEFAULT)
    layoutdata.left = Swt::Layout::FormAttachment.new( special_gem_label_ex, -1, Swt::SWT::LEFT)
    layoutdata.top = Swt::Layout::FormAttachment.new( special_gem_label_ex, 2, Swt::SWT::BOTTOM)
    gem_path_text = Swt::Widgets::Text.new(composite, Swt::SWT::BORDER)
    gem_path_text.setText(App::CONFIG['gem_path'] || '')
    gem_path_text.setEnabled(@use_specify_gem_path_btn.getSelection)
    gem_path_text.setLayoutData( layoutdata )
    gem_path_text.addListener(Swt::SWT::Selection, compass_version_button_handler)

    @use_specify_gem_path_btn.addListener(Swt::SWT::Selection,Swt::Widgets::Listener.impl do |method, evt|   
      gem_path_text.setEnabled(evt.widget.getSelection)

    end)
    
    layoutdata = Swt::Layout::FormData.new()
    layoutdata.left = Swt::Layout::FormAttachment.new(button_group, 0, Swt::SWT::LEFT)
    layoutdata.top = Swt::Layout::FormAttachment.new(gem_path_text, 10, Swt::SWT::BOTTOM)
    @apply_group =Swt::Widgets::Composite.new(composite, Swt::SWT::NO_MERGE_PAINTS );
    rowlayout = Swt::Layout::RowLayout.new(Swt::SWT::VERTICAL) 
    rowlayout.marginBottom = 0;
    rowlayout.spacing = 10;
    @apply_group.setLayout( rowlayout );
    @apply_group.setLayoutData( layoutdata )
    @apply_group.setVisible(false)

    special_gem_label_ex = Swt::Widgets::Label.new( @apply_group, Swt::SWT::LEFT | Swt::SWT::WRAP)
    special_gem_label_ex.setText("You have to restart Commpass.app to apply this change")

    compass_version_apply_button = Swt::Widgets::Button.new(@apply_group, Swt::SWT::PUSH )
    compass_version_apply_button.setText("Apply && Quit")
    compass_version_apply_button.addListener(Swt::SWT::Selection,Swt::Widgets::Listener.impl do |method, evt|   
      if @button_v11.getSelection
        App::CONFIG['use_version'] = 0.11
      elsif  @button_v10.getSelection
        App::CONFIG['use_version'] = 0.10
      else
        App::CONFIG['use_version'] = false
      end
      App::CONFIG['use_specify_gem_path']=@use_specify_gem_path_btn.getSelection
      App::CONFIG['gem_path']=gem_path_text.getText
      App.save_config
      evt.widget.shell.dispose();
      Tray.instance.stop_watch
      java.lang.System.exit(0)
    end)


    return composite;
  end

  def compass_version_button_handler 
    Swt::Widgets::Listener.impl do |method, evt|   
      if ( @button_v11.getSelection && App::CONFIG['use_version'] == 0.11 ) || 
         ( @button_v10.getSelection && App::CONFIG['use_version'] == 0.10 ) ||
         ( @use_specify_gem_path_btn.getSelection && App::CONFIG['use_version'] == false )
        @apply_group.setVisible(false)
      else
        @apply_group.setVisible(true)
      end 
    end
  end
end
