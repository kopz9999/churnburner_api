module ChurnburnerApi
  module ETL
    class IntercomCompanies
      include Singleton
      include ChurnburnerApi::ETL::IntercomHelper

      def import_csv(path)
        File.open(path, "r") do |f|
          f.each_line(&method(:process_line))
        end
      end

      def process_line(line)
        return if line.blank?
        parts = line.gsub(/\"/, '').split(',')
        name = parts[0]
        email = parts[1].downcase
        company_name = parts[2].gsub(/(\n|\r)/, '')
        fub_user = Fub::User.find_by email: email
        if fub_user.nil?
          fub_user = Fub::User.create(email: email, name: name)
        end
        intercom_user = setup_intercom_user(fub_user)
        if intercom_user.nil?
          company = company_fub_user company_name, fub_user
          fub_user.set_default_company company
          self.intercom_client.companies.create(company.to_intercom_hash)
        else
          fub_user.update(intercom_id: intercom_user.id)
          process_user intercom_user, fub_user, company_name
        end
      end

      def company_fub_user(company_name, fub_user)
        company = Company.find_or_create_by(name: company_name)
        company.email_data ||=
          company.create_email_data(value: fub_user.email)
        company
      end

        # @param [Intercom::User] intercom_user
      def process_user(intercom_user, fub_user, company_name)
        if intercom_user.companies.blank?
          if !intercom_user.custom_attributes.blank? &&
            (raw_company_name = intercom_user.custom_attributes['company_name']) &&
            !raw_company_name.blank? &&
            (company_name = raw_company_name.gsub('"', '')) && !company_name.blank?
            company = setup_intercom_company(intercom_user, company_name)
          else
            company = company_fub_user company_name, fub_user
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
