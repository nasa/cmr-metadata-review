# frozen_string_literal: true

# create a status checkup interface
class MiddlewareHealthcheck
  def initialize(app)
    @app = app
  end

  # this is the Middleware handler
  def call(env)
    if env['PATH_INFO'] == '/status'
      handle_health_check_call
    else
      @app.call(env)
    end
  end

  # handle the health check call
  def handle_health_check_call
    db_healthy, status = check_database_health

    response = [status, header_values, document_output(db_healthy)]
    unless status == 200
      Rails.logger.info "The Status page returned a #{response[0]} "\
        "Response:#{response.inspect}"
    end
    response
  end

  # construct the JSON output based on test results
  def document_output(db_healthy)
    ["{\"database\": #{db_healthy}}"]
  end

  # return the HTML headers to be used for this call
  def header_values
    {
      'X-Powered-By' => 'CMR-Dashboard',
      'X-Version' => Rails.application.config.version.to_s,
      'Content-Type' => 'application/json'
    }
  end

  # checks the database health
  def check_database_health
    begin
      db_healthy = ActiveRecord::Migrator.current_version != 0
      status = 200
    rescue StandardError => e
      Rails.logger.error "Database error: #{e}"
      db_healthy = false
      status = 503
    end
    [db_healthy, status]
  end
end
