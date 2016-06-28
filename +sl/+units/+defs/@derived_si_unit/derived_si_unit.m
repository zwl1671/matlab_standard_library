classdef derived_si_unit
    %
    %   Class:
    %   si.units.defs.derived_si_unit
    
    properties
       %Common - TODO: make abstract 
       unit_type = 'si'
       quantity_type
       raw
       short
       long
       in_base_units
       quantity_array
    end
    
    methods (Static)
        function createIfMatching(str)
           obj_or_null = h__match_SI_unit(str); 
        end
    end
    
end

function obj = h__match_SI_unit(str)
%
%   - change name to getBaseUnitInfo

obj = sl.units.defs.derived_si_unit();

obj.raw = str;

obj.quantity_array = zeros(1,7);

%mass
switch str
    case {'Hz' 'hertz'}
        obj.short = 'Hz';
        obj.long  = 'hertz';
        obj.quantity_type  = 'frequency';
        obj.in_base_units = {'s' -1};
        obj.quantity_array(7) = -1; 
    case {'N' 'newton'}
        obj.short = 'N';
        obj.long = 'newton';
        obj.quantity_type = 'force';
        obj.quantity_array(3) = 1; %m
        obj.quantity_array(5) = 1; %kg
        obj.quantity_array(7) = -2; %s^-2
    case {'Pa' 'pascal'}
        obj.short = 'Pa';
        obj.long = 'pascal';
        obj.quantity_type = 'pressure, stress';
        %                           %N / m^2
        obj.quantity_array(3) = -1; %m   / m^2
        obj.quantity_array(5) = 1;  %kg
        obj.quantity_array(7) = -2; %s^-2
    case {'J' 'joule'}
        obj.short = 'J';
        obj.long = 'joule';
        obj.quantity_type = 'energy, work, quantity of heat';
        %                           %N * m
        obj.quantity_array(3) = 2;  %m      m
        obj.quantity_array(5) = 1;  %kg
        obj.quantity_array(7) = -2; %s^-2
    case {'W' 'watt'}
        obj.short = 'W';
        obj.long = 'watt';
        obj.quantity_type = 'power, radiant flux';
        %                    %J/s
        %obj.quantity_array
    case {'C' 'coulomb'}
        obj.short = 'C';
        obj.long  = 'coulomb';
        obj.quantity_type = 'electric charge, quantity of electricity';
        %                    s*A
        obj.quantity_array(7) = 1;
        obj.quantity_array(2) = 1;
    case {'V' 'volt'}
    case {'F' 'farad'}
    
    %Ohm    
    %case {
    case {'S' 'siemens'}
    case {'Wb' 'weber'}
    case {'T' 'tesla'}
    case {'H' 'henry'}
    case {'degC' 'degree celsius'}
    case {'lm' 'lumen'}
    case {'lx' 'lux'}
    case {'Bq' 'becquerel'}
    case {'Gy' 'gray'}
    case {'Sv' 'sievert'}
    case {'kat' 'katal'}
        
        
            
        
    %TODO: finish - http://physics.nist.gov/cuu/Units/units.html
end

if isempty(obj.quantity_type)
    obj = [];
end

end