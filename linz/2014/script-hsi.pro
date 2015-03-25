t1 = '11-Dec-2014 ' + ['19:00:00','19:30:00']

obs_obj = hsi_obs_summary( obs_time_interval=t1 )
obs_obj->plotman, /ylog

;
; SPEX
;

t_int = '11-Dec-2014 ' + ['19:00:00','19:30:00']

obs_obj = hsi_obs_summary()
obs_obj-> set, obs_time_interval= t_int
obs_obj-> plotman, /ylog

obj = hsi_spectrum()
obj-> set, obs_time_interval= t_int
obj-> set, decimation_correct= 1                                                             
obj-> set, rear_decimation_correct= 0                                                        
obj-> set, pileup_correct= 0                                                                 
obj-> set, seg_index_mask= [1B, 0B, 0B, 0B, 0B, 0B, 0B, 0B, 0B, $
							0B, 0B, 0B, 0B, 0B, 0B, 0B, 0B, 0B]
obj-> set, sp_chan_binning= 0
obj-> set, sp_chan_max= 0
obj-> set, sp_chan_min= 0
obj-> set, sp_data_unit= 'Flux'
obj-> set, sp_energy_binning= 22L
obj-> set, sp_semi_calibrated= 0B
obj-> set, sp_time_interval= 30
obj-> set, sum_flag= 1
obj-> set, time_range= [0.0000000D, 0.0000000D]
obj-> set, use_flare_xyoffset= 1

data = obj->getdata()    ; retrieve the spectrum data
;obj-> plot               ; plot the spectrum
;obj-> plotman            ; plot the spectrum in plotman
;obj-> plot, /pl_time     ; plot the time history
;obj-> plotman, pl_time   ; plot the time history in plotman

specfile = 'linz/hsi_spec_20121102_30sec_D1.fits'
srmfile = 'linz/hsi_srm_20121102_30sec_D1.fits'
obj->filewrite, /buildsrm, all_simplify = 0, srmfile = srmfile, specfile = specfile



obj = ospex()
obj-> set, spex_specfile= 'linz/hsi_spec_20121102_30sec_D1.fits'
obj-> set, spex_drmfile= 'linz/hsi_srm_20121102_30sec_D1.fits'
obj-> set, spex_bk_time_interval=[' 2-Nov-2012 17:50:30.000', ' 2-Nov-2012 17:53:00.000']
obj-> set, spex_fit_time_interval= [[' 2-Nov-2012 18:01:30.000', ' 2-Nov-2012 18:02:00.000']]

; 0.00753, 0.732
; 0.00588, 0.751
; 0.00400, 0.827

; 0.00671391, 0.745797
; 

obj-> set, spex_erange = [6.,100.]
;obj-> set, spex_erange = -1

obj -> dofit, /all                                                                                     
obj -> savefit

;
; RHESSI images
;

t2 = '11-Dec-2014 ' + ['19:13:00','19:13:50']
t2 = '11-Dec-2014 ' + ['19:19:00','19:20:00']

obj = hsi_image()
obj-> set, det_index_mask= [0B, 0B, 1B, 0B, 1B, 1B, 1B, 1B, 0B]
obj-> set, im_energy_binning= [4., 12.]
obj-> set, im_time_interval= t2
obj-> set, image_dim= [256, 256]
obj-> set, pixel_size= [4., 4.]
;obj-> set, use_auto_time_bin= 1L
;obj-> set, use_flare_xyoffset= 1L
obj-> set, xyoffset = [-80,80]

obj-> set, smoothing_time= 4.0
obj-> set, use_phz_stacker= 1L

obj-> set, image_algorithm= 'Clean'
;obj-> set, natural_weighting= 1L
;obj-> set, uniform_weighting= 0L
;obj -> set,clean_show_maps=0L
obj-> set, clean_niter = 300
;obj-> set, clean_beam_width_factor = 1.5

;obj -> set, CLEAN_REGRESS_COMBINE=1L

;obj-> set, image_algorithm= 'MEM_NJIT'
;obj-> set, image_alg = 'EM'

data = obj-> getdata()
obj-> plotman
obj->fitswrite

cfits2maps, 'hsi_clean_191300.fits', hsi


;
; RHESSI SPEX from Säm
;

restore,'rhessi_spectral_fit_foxsi_flare_September2014.sav',/verbose
plot_oo,average(ebins,1),obs_all(*,0),xrange=[4,12],xstyle=1,yrange=[1e-3,1e4], psym=10
    for i=0,det_dim-1 do oplot,average(ebins,1),obs_all(*,i), psym=10
    ;for i=0,det_dim-1 do oplot,average(ebins,1),bkg_all(*,i), psym=10
    oplot,average(ebins,1),average(bkg_all,2),thick=3,color=1, psym=10
    oplot,average(ebins,1),average(ph_all,2),thick=3,color=6, psym=10
