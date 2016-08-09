module Fub
  class Person < ::User
    module Factory
      def retrieve_fub_lead(fub_person)
        lead = self.retrieve_fub fub_person
        lead.fub_lead = true
        lead.converted_at = Time.parse(fub_person.created)
        lead.mark_pending
        lead.save
        lead
      end
    end

    extend Factory

    default_scope { where(fub_lead: true) }

    has_one :fub_lead_datum
    delegate :mark_pending, :mark_synced, :converted_at, :converted_at=,
             to: :fub_lead_datum

    after_create :create_fub_lead_datum

    # @param [Intercom::Contact] intercom_contact
    def setup_intercom_contact(intercom_contact)
      intercom_contact.custom_attributes["fub_lead"] = true
      intercom_contact.custom_attributes["converted_at"] =
        self.fub_lead_datum.converted_at
      intercom_contact.custom_attributes["synced_at"] =
        self.fub_lead_datum.synced_at
      intercom_contact.companies = [self.default_company.to_intercom_hash]
    end
  end
end
