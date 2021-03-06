# frozen_string_literal: true

module SidekiqUniqueJobs
  module Middleware
    # The unique sidekiq middleware for the client push
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    class Client
      prepend SidekiqUniqueJobs::Middleware

      # Calls this client middleware
      #   Used from Sidekiq.process_single
      #
      # @see SidekiqUniqueJobs::Middleware#call
      #
      # @see https://github.com/mperham/sidekiq/wiki/Job-Format
      # @see https://github.com/mperham/sidekiq/wiki/Middleware
      #
      # @yield when uniqueness is disable
      # @yield when the lock is successful
      def call(*)
        lock { yield }
      end

      private

      def lock
        if (token = lock_instance.lock)
          yield token
        else
          warn_about_duplicate
        end
      end

      def warn_about_duplicate
        return unless log_duplicate?

        log_warn "Already locked with another job_id (#{dump_json(item)})"
      end
    end
  end
end
