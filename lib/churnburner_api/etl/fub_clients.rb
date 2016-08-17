module ChurnburnerApi
  module ETL
    class FubClients
      include Singleton
      include ChurnburnerApi::ETL::IntercomHelper

      def intercom_tag
        "Users FUB CSV - #{self.ran_at}"
      end

      def import_csv(path)
        File.open(path, "r") do |f|
          f.each_line(&method(:process_line))
        end
      end

      def process_line(line)
        return if line.blank?
        Rails.logger.info line
        parts = line.split(',')
        name = parts[0]
        email = parts[1].downcase
        api_key = parts[2].gsub(/(\n|\r)/, '')
        fub_user = Fub::User.find_by email: email
        if fub_user.nil?
          fub_user = Fub::User.create(email: email, name: name)
        end
        intercom_user = setup_intercom_user(fub_user)
        if intercom_user.nil?
          company = Company.fub_user fub_user
          fub_user.set_default_company company
          retrieve_intercom_company company
        else
          fub_user.update(intercom_id: intercom_user.id)
          process_user intercom_user, fub_user
          tag_user intercom_tag, fub_user
        end
        fub_user.fub_client_datum.update(api_key: api_key, active: true)
      end

      # @param [Intercom::User] intercom_user
      # @return [Company]
      def process_user(intercom_user, fub_user)
        if intercom_user.companies.blank?
          if !intercom_user.custom_attributes.blank? &&
            (raw_company_name = intercom_user.custom_attributes['company_name']) &&
            !raw_company_name.blank? &&
            (company_name = raw_company_name.gsub('"', '')) && !company_name.blank?
            company = setup_intercom_company(intercom_user, company_name)
          else
            company = Company.fub_user fub_user
            tag_company intercom_tag, company
          end
        else
          companies = intercom_user.companies
                        .map { |ic| Company.retrieve_intercom_company(ic) }
          company = companies.first
        end
        fub_user.set_default_company company
        intercom_user.companies = [company.to_intercom_hash]
        self.intercom_client.users.save(intercom_user)
      end
    end
  end
end
