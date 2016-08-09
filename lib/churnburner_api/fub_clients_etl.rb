module ChurnburnerApi
  class FubClientsETL
    include Singleton
    include IntercomWorker

    def import_csv(path)
      File.open(path, "r") do |f|
        f.each_line do |line|
          parts = line.split(',')
          email = parts[0]
          name = parts[1]
          api_key = parts[2]
          fub_user = Fub::User.find_by email: email
          if fub_user.nil?
            fub_user = Fub::User.create(email: email, name: name)
            fub_user.api_key = api_key
          end
          begin
            intercom_user = intercom_client.users.find(email: fub_user.email)
          rescue Intercom::ResourceNotFound
            intercom_user = nil
          end
          if intercom_user.nil?
            intercom_user = intercom_client.users
                              .create(email: fub_user.email,
                                      name: fub_user.name)
          end
          fub_user.active = true
          fub_user.intercom_id = intercom_user.id
          fub_user.save
          process_user intercom_user, fub_user
        end
      end
    end

    # @param [Intercom::User] intercom_user
    def process_user(intercom_user, fub_user)
      if intercom_user.companies.blank?
        if !intercom_user.custom_attributes.blank? &&
          (raw_company_name = intercom_user.custom_attributes['company_name']) &&
          !raw_company_name.blank? &&
          (company_name = raw_company_name.gsub('"', '')) && !company_name.blank?
          company = find_company intercom_user, company_name
        else
          company = Company.create name: "#{fub_user.name} Company"
          company.company_identifier = company.id.to_s
          company.save
          company
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

    # @return [Company]
    def find_company(intercom_user, company_name)
      company = Company.find_by name: company_name
      if company.nil?
        begin
          intercom_company =
            self.intercom_client.companies.find(name: company_name)
        rescue Intercom::ResourceNotFound
          intercom_company = nil
        end
        company = intercom_company.nil? ?
          Company.intercom_user(intercom_user) :
          Company.intercom_company(intercom_company)
      end
      company
    end
  end
end
