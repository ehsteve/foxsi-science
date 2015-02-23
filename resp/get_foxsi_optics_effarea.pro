FUNCTION get_foxsi_optics_effarea, ENERGY_ARR = energy_arr, MODULE_NUMBER = module_number, $
	OFFAXIS_ANGLE = offaxis_angle, PLOT = plot, _EXTRA = _extra, ORIG_DATA = orig_data

;PURPOSE: Get the FOXSI optics effective area in cm^2 as a function of energy
;           and off-axis angle.
;
;KEYWORD:   MODULE_NUMBER - the module number (0 through 6)
;			PLOT - plot to the current device
;			OFFAXIS_ANGLE - off-axis angle. if array then [pan, tilt] in arcmin
;           ORIG_DATA - return the original data structure
;
;WRITTEN: Steven Christe (21-Jan-15)
;UPDATED: Steven Christe (17-Jan-15)

default, data_dir, '../calibration_data/'
default, offaxis_angle, [0.0, 0.0]
default, module_number, 0

dim = 2

IF n_elements(offaxis_angle) EQ 1 THEN angle = 1/sqrt(2) * [offaxis_angle, offaxis_angle] $
    ELSE angle = offaxis_angle

files = data_dir + 'FOXSI2_' + ['Module_X-' + num2str(module_number) + '_EA_pan.txt', $
         'Module_X-' + num2str(module_number) + '_EA_tilt.txt']

; todo: these need to be provided by the data files themselves
angles = [-9, -7, -5, -3, -1, 0, 1, 3, 5, 7, 9]
energy = [4.5,  5.5,  6.5,  7.5,  8.5,  9.5, 11. , 13. , 15. , 17. , 19. , 22.5, 27.5]

FOR i = 0, n_elements(files)-1 DO BEGIN
    ; the following code is dumb, need something that detects num of columns
    ; i hate readcol
    readcol, files[i], d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, skipline = 4, /silent
    IF i EQ 0 THEN data = fltarr(2, n_elements(angles), n_elements(d0))
    data[i, 0, *] = d0
    data[i, 1, *] = d1
    data[i, 2, *] = d2
    data[i, 3, *] = d3
    data[i, 4, *] = d4
    data[i, 5, *] = d5
    data[i, 6, *] = d6
    data[i, 7, *] = d7
    data[i, 8, *] = d8
    data[i, 9, *] = d9
    data[i, 10, *] = d10
ENDFOR

orig_data = create_struct('angles', angles, 'energies', energy, 'data', data)

IF keyword_set(energy_arr) THEN BEGIN
    interpol_data = fltarr(dim, n_elements(data[0, *, 0]), n_elements(energy_arr))
    ; interpolate data on new energies    
    FOR j = 0, dim - 1 DO BEGIN
        FOR i = 0, n_elements(angles)-1 DO BEGIN
            eff_area = data[j, i, *]
            interpol_data[j, i, *] = interpol(eff_area, energy, energy_arr)
        ENDFOR
    ENDFOR
ENDIF ELSE BEGIN 
    interpol_data = data
	energy_arr = energy
ENDELSE

rnorm = sqrt(angle[0] ^ 2 + angle[1] ^ 2)
sign = angle / abs(angle)
IF rnorm EQ 0 THEN phi = 0 ELSE phi = atan(abs(angle[1] / angle[0]) )
IF angle[0] EQ 0 THEN sign[0] = 1
IF angle[1] EQ 0 THEN sign[1] = 1
; now interpolate to the requested off-axis angle
eff_area = fltarr(2, n_elements(energy_arr))
FOR j = 0, dim - 1 DO FOR i = 0, n_elements(energy_arr)-1 DO BEGIN
    eff_area[j, i] = interpol(interpol_data[j, *, i], angles, rnorm * sign[j])
ENDFOR

; now interpolate between pan and tilt
m = (eff_area[1, *] - eff_area[0, *]) / !pi/2. 
result = eff_area[0, *] + m * phi

;print, eff_area

eff_area = result
;eff_area = eff_area[1, *]


IF keyword_set(PLOT) THEN BEGIN
	plot, energy_arr, reform(eff_area), psym = -4, $
		xtitle = "Energy [keV]", ytitle = "Effective Area [cm!U2!N]", $
		charsize = 1.5, /xstyle, xrange = [min(energy_arr), max(energy_arr)], $
		_EXTRA = _EXTRA, /nodata
	oplot, energy_arr, reform(eff_area), psym = -4
	ssw_legend, 'pan, tilt = [' + num2str(angle[0]) + ',' + num2str(angle[1]) + ']'
ENDIF

result = create_struct("energy_keV", energy_arr, "eff_area_cm2", eff_area)

RETURN, result

END