classdef logic < handle
    properties
        SourceFile
        SourceImage
        WMFile
        WMImage
        Psize
        Alpha
        Sy
        Uw
        Vw
        I_1
        EmbedEnable
        WatermarkedImage
    end
    methods (Access = public)
        function initializeSource(this, SourceFile, type)
            this.SourceFile = SourceFile;
            this.SourceImage = imread( this.SourceFile);
            
            % Input ust be 2D matrix for svd.
            % Check for type recieved in input and alter image as per it.
            % For grayscale additionally check if image is already
            % grayscaled.
            % If image is grayscale, dont allow R,G,B component type.
            if strcmp(type,'Grayscale') == 1 && size(this.SourceImage,3) ~= 1
                this.SourceImage = rgb2gray(this.SourceImage);
            elseif size(this.SourceImage,3) ~= 1
                if strcmp(type,'R Component') == 1
                    this.SourceImage = this.SourceImage(:,:,1);
                elseif strcmp(type,'G Component') == 1
                    this.SourceImage = this.SourceImage(:,:,2);
                elseif strcmp(type,'B Component') == 1
                    this.SourceImage = this.SourceImage(:,:,3);
                end
            end
            
            [LL1,~,~,~] = dwt2(this.SourceImage,'haar');
            [LL2,~,~,~] = dwt2(LL1,'haar');
            this.Psize = size(LL2);
            
            % Set EmbedEnable if WMImage is set
            if ~isempty(this.WMImage)
                this.EmbedEnable = 1;
            end
        end
        
        function alteredWM = initializeWM(this, WMFile, type)
            this.WMFile = WMFile;
            WMImg = imread(this.WMFile);
            
            % Input ust be 2D matrix for svd.
            % Check for type recieved in input and alter image as per it.
            % For grayscale additionally check if image is already
            % grayscaled.
            % If image is grayscale, dont allow R,G,B component type.
            if strcmp(type,'Grayscale') == 1 && size(WMImg,3) ~= 1
                alteredWM = rgb2gray(WMImg);
            elseif size(WMImg,3) ~= 1
                if strcmp(type,'R Component') == 1
                    alteredWM = WMImg(:,:,1);
                elseif strcmp(type,'G Component') == 1
                    alteredWM = WMImg(:,:,2);
                elseif strcmp(type,'B Component') == 1
                    alteredWM = WMImg(:,:,3);
                end
            else
                alteredWM = WMImg;
            end

            % size(SourceImage) = size(WMImage) for blending
            this.WMImage = imresize(alteredWM, this.Psize);
            
            % Set EmbedEnable if SourceImage is set
            if ~isempty(this.SourceImage)
                this.EmbedEnable = 1;
            end
        end
        
        function embed(this, Alpha)
            this.Alpha = Alpha;
            [LL1,HL1,LH1,HH1] = dwt2(this.SourceImage,'haar');
            [LL2,HL2,LH2,HH2] = dwt2(LL1,'haar');
            [Uy,this.Sy,Vy] = svd(LL2);
            [this.Uw,Sw,this.Vw] = svd(double(this.WMImage));
            Smark = this.Sy + Alpha*Sw;
            LL2_1 = Uy*Smark*Vy';
            LL1_1 = idwt2(LL2_1,HL2,LH2,HH2,'haar');
            
            % size(cA) = size(cH) = size(cV) = size(cD) must be same for idwt2
            LL1_1 = imresize(LL1_1,size(HL1));
            
            this.I_1 = idwt2(LL1_1,HL1,LH1,HH1,'haar');
            this.WatermarkedImage = uint8(this.I_1);
        end
        
        function ExtractedImage = extract(this)
            [LL1_wmv,~,~,~] = dwt2(this.I_1,'haar');
            [LL2_wmv,~,~,~] = dwt2(LL1_wmv,'haar');
            [~,Sy_wmv,~] = svd(LL2_wmv);
            Swrec = (Sy_wmv - this.Sy)/this.Alpha;
            WMy = this.Uw*Swrec*this.Vw';    
            ExtractedImage = uint8(WMy);
        end
    end
    methods(Access = public)
        function this = logic
        end
    end
end
