class Product < ActiveRecord::Base
     has_many :branchOffices
     belongs_to :loan
     belongs_to :payout
     has_many :credits
     validates :nombre_del_producto,
     :registro_del_contrado_de_adhesion,
     :plazo_de_prestamo,
     :numero_de_pagos_a_realizar,
     :taza_de_interes_ordinaria,
     :taza_de_interes_moratoria,
     :cat_sin_iva,
     :plazo,
     :numero_de_meses_de_sueldo_para_prestamo,
     :loan_id,
     :payout_id,
     presence:true
     
     def fechas_de_impresion
          arr = Payment.joins(:credit=>:product).select(:fecha_de_impresion).where("products.id = ?",self.id).uniq.where("payments.fecha_de_pago < ? ",Time.now + 1.month)
            
          while (arr.last.fecha_de_impresion <= Time.now)
               arr << Payment.new(fecha_de_impresion:Auxiliar.getArreglo(self,arr.last.fecha_de_impresion)["impresion"])
          end
          arr
     end
     def fechas_de_corte
          arr = Payment.select(:fecha_de_corte).joins(:credit=>:product).where("credits.status = ? ",1 ).where("products.id = ? ", self.id).uniq.order(:fecha_de_corte)
          
          while (arr.last.fecha_de_corte <= Time.now)
               arr << Payment.new(fecha_de_corte:Auxiliar.getArreglo(self,arr.last.fecha_de_corte)["corte"])
          end
          arr
     end
     def ultimaFechaDeCorte
          fp = Payment.select(:fecha_de_pago,:fecha_de_corte).joins(:credit=>:product).where("credits.status = ? ",1 ).where("products.id = ? ", self.id).uniq.order(:fecha_de_pago)
          while (fp.last.fecha_de_corte <= Time.now)
               fp << Payment.new(fecha_de_corte:Auxiliar.getArreglo(self,fp.last.fecha_de_corte)["corte"],fecha_de_pago:Auxiliar.getArreglo(self,fp.last.fecha_de_corte)["pago"])
          end
          fp.reverse.each do |fechas|
               return fechas if fechas.fecha_de_corte.to_date <= Time.now.to_date
          end
     end
     def proximaFechaDeCorte
          fp = Payment.select(:fecha_de_pago,:fecha_de_corte).joins(:credit=>:product).where("credits.status = ? ",1 ).where("products.id = ? ", self.id).uniq.order(:fecha_de_pago)
          while (fp.last.fecha_de_corte <= Time.now)
               fp << Payment.new(fecha_de_corte:Auxiliar.getArreglo(self,fp.last.fecha_de_corte)["corte"],fecha_de_pago:Auxiliar.getArreglo(self,fp.last.fecha_de_corte)["pago"])
          end
          fp.each do |fechas|
               return fechas if fechas.fecha_de_corte.to_date > Time.now.to_date
          end
     end
     def vencer
          fecha = Time.now.to_date
          if self.ultimaFechaDeCorte.fecha_de_corte == fecha
               Payment.joins(:credit).where("credits.product_id = ?",self.id)
               .where("payments.fecha_de_pago <= ?",fecha).where.not(estatus:2).each do |p|
                    p.cargar_interes
               end
               tuplas = Auxiliar.seguimiento_por_creditos(self.credits.where(status:1).order(:apellido_paterno), fecha)
               tuplas.each do |t|
                    Seguimiento.create(
                         nombre:t["nombre_completo"], 
                         fecha_prestamo:t["fecha"], 
                         capital:t["monto_solicitud"], 
                         monto_a_cobrar:t["monto_a_pagar"],
                         adeudo:t["adeudo"], 
                         a_pagar:t["pagar"], 
                         atrasado:t["atrasado"], 
                         interés_moratorio:t["interes_moratorio"], 
                         total_a_cobrar:t["total_a_cobrar"], 
                         cobrado:t["cobrado"], 
                         diferencia:t["diferencia"],
                         adelantado:t["adelantado"], 
                         empresa:t["empresa"],
                         no_pago:t["numero_de_pago"], 
                         no_creditos:t["numero_de_creditos"],
                         payment_id:t["payment_ref"]
                    )
               end
          end
     end
end
