module ChurnburnerApi
  module ETL
    module IntercomHelper
      include IntercomWorker

      def intercom_tag
        raise NotImplementedError
      end

      # @param [Fub::User] fub_user
      # @return [Intercom::User]
      def setup_intercom_user(fub_user)
        begin
          intercom_user = intercom_client.users.find(email: fub_user.email)
        rescue Intercom::ResourceNotFound
          intercom_user = nil
        rescue Intercom::MultipleMatchingUsersError
          # Bug on Intercom API
          return nil
        end
        if intercom_user.nil?
          intercom_user = intercom_client.users
                            .create(email: fub_user.email,
                                    name: fub_user.name)
        end
        intercom_user
      end

      # @param [Intercom::User] intercom_user
      # @param [String] company_name
      # @return [Company]
      def setup_intercom_company(intercom_user, company_name)
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

      # @param [Company] company
      # @return [Intercom::Company]
      def retrieve_intercom_company(company)
        begin
          intercom_company =
            self.intercom_client.companies.find(name: company.name)
        rescue Intercom::ResourceNotFound
          intercom_company = nil
        end
        if intercom_company.nil?
          intercom_company =
            self.intercom_client.companies.create(company.to_intercom_hash)
          tag_company intercom_tag, company
        end
        intercom_company
      end

      # @param [String] email
      # @param [String] name
      # @return [Fub::User]
      def retrieve_fub_user(email, name)
        # @type [User]
        user = ::User.find_by email: email
        if user.nil?
          fub_user = Fub::User.create(email: email, name: name)
        else
          user.to_fub_user unless user.fub_client?
          fub_user = Fub::User.find_by email: email
        end
        fub_user
      end
    end
  end
end
