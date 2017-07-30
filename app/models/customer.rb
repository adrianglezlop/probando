class Customer < ActiveRecord::Base
  belongs_to :economical_activity
  belongs_to :ocupation
  has_many :credits
  validates :RFC, uniqueness: true
  validates :CURP, uniqueness: true
  def nombres 
    self.nombre_1 + " " + self.nombre_2
  end
  
   validates_format_of :RFC, :with => /([A-Z][A-Z]|[A-Z])[A-Z][A-Z]\d\d\d\d\d\d(\w\w\w|)/
    #eee555555eee
     validates_format_of :CURP, :with => /[A-Z][A-Z][A-Z][A-Z]\d\d\d\d\d\d\w\w\w\w\w\w\d\d/
     #BEML920313HCMLNS09.
    
    def padre 
        if agente_empresa==1
          return  Agent.find(self.referencia_agente_empresa)
        else
          return  Company.find(self.referencia_agente_empresa)
        end
    end
end
