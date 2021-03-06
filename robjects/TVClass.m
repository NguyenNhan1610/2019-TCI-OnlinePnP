classdef TVClass < RegularizerClass
    % Class for implementing TV regularization.
    %
    % U. S. Kamilov, CIG, WUSTL, 2017.
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % public properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties
        sigSize; % size of the signal
        tau; % regularization parameter
        bc = 'reflexive'; % boundary conditions
        bounds = [-inf, +inf]; % bound constraints
        maxiter = 100; % maximal number of iterations
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        function this = TVClass(sigSize, tau, varargin)
            %  constuctor
            
            this.sigSize = sigSize;
            this.tau = tau;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Parse optional input
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            nargs = length(varargin); % Number of options
            
            for i = 1:2:nargs % Go through options
                
                name = lower(varargin{i}); % Extract name
                value = varargin{i+1}; % Extract value
                
                switch(name)
                    case 'bc'
                        this.bc = value;
                    case 'bounds'
                        this.bounds = value;
                    case 'maxiter'
                        this.maxiter = value;
                    otherwise
                        error('TVClass: input is not recognized!');
                end
            end
        end
        
        function p = init(this)
            % returns dual initializer
            
            p = zeros([this.sigSize 2]);
        end
        
        function r = eval(this, x)
            % evaluate TV
            
            dx = shift(x, [-1,0], this.bc)-x;
            dy = shift(x, [0,-1], this.bc)-x;
            r = this.tau*sum(sum(sqrt(abs(dx).^2+abs(dy).^2)));
        end
        
        function [x, pout] = prox(this, z, step, pin, ratio)
            % run TV proximal
            
            [x, pout] = denoiseTV(z, step*this.tau*ratio,...
                'bc', this.bc,...
                'maxiter', this.maxiter,...
                'bounds', this.bounds,...
                'P', pin);
        end
        
    end
    
end