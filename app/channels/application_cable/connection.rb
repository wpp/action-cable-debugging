module ApplicationCable
  class Connection < ActionCable::Connection::Base
    def connect
      logger.info "Connection.connect"
    end

    def disconnect
      logger.info "Connection.disconnect"
    end
  end
end
