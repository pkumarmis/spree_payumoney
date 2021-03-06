require "offsite_payments"
module Spree
  class Gateway::Payumoney < Gateway
    preference :merchant_id, :string
    preference :secret_key, :string

      
    def provider_class
      ::OffsitePayments.integration('Payu_In')
    end

    def provider
      #assign payment mode
      OffsitePayments.mode = preferred_test_mode == true ? :test : :production
      provider_class
    end

    def checksum(items)
      provider_class.checksum(preferred_merchant_id, preferred_secret_key, items)
    end    

    def auto_capture?
      true
    end

    def method_type
      "payumoney"
    end

    def support?(source)
      true
    end

    def authorization
      self
    end

    def purchase(amount, source, gateway_options={})
      ActiveMerchant::Billing::Response.new(true, "payumoney success")
    end

    def success?
      true
    end

    def txnid(order)
      order.id.to_s + order.number.to_s
    end

    def service_provider
      "payu_paisa"
    end

    def checksum_ok?(order, payu_txnid, payu_amount)
      txnid(order) == payu_txnid && order.total.to_f.round(2) == payu_amount.to_f.round(2)
      # Digest::SHA512.hexdigest([preferred_secret_key, *itms, preferred_merchant_id].join("|")) == pg_hash
    end

    def amount_ok?(order_total, pg_amount)
      BigDecimal.new(pg_amount) == order_total
    end

    def source_required?
      false
    end
  end
end