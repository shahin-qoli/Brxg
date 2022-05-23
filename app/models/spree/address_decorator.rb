module Spree::AddressDecorator
	def postal_code_validate
		return if country.blank? || country_iso.blank? || !require_zipcode? || zipcode.blank?
        return unless ::ValidatesZipcode::CldrRegexpCollection::ZIPCODES_REGEX.keys.include?(country_iso.upcase.to_sym)
        errors.add(:zipcode, :invalid) unless zipcode.to_s.strip == 
    end
end

Spree::Address.prepend(Spree::AddressDecorator)        