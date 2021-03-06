      subroutine rdcsss
c
c --- ------------------------------------------------------------------
c --- Read monthly climatological sea surface salinity
c --- ------------------------------------------------------------------
c
      use mod_xc
      use netcdf
c
      implicit none
c
#include "common_blocks.h"
#include "common_forc.h"
c
      real, dimension(itdm,jtdm) :: tmp2d
      integer, dimension(3) :: start,count
      integer i,j,k,status,ncid,dimid,varid
      character filename*120
c
      if (mnproc.eq.1) then
        if     (srxsrc.eq.'PHC3.0') then
          filename='sss_clim_phc3.0.nc'
        elseif (srxsrc.eq.'CORE') then
          filename='sss_clim_core.nc'
        endif
        write (lp,'(2a)') ' reading monthly climatological SSS from ',
     .                    path(1:path_len)//trim(filename)
        call flush(lp)
c
c --- - open netcdf file
        status=nf90_open(path(1:path_len)//trim(filename),
     .                   nf90_nowrite,ncid)
        if (status.ne.nf90_noerr) then
          write(lp,'(4a)') 'nf90_open: ',trim(filename),': ',
     .                     nf90_strerror(status)
          call xchalt('(rdcsss)')
                 stop '(rdcsss)'
        endif
c
c --- - check dimensions
        status=nf90_inq_dimid(ncid,'x',dimid)
        if (status.ne.nf90_noerr) then
          write(lp,'(2a)') 'nf90_inq_dimid: x: ',nf90_strerror(status)
          call xchalt('(rdcsss)')
                 stop '(rdcsss)'
        endif
        status=nf90_inquire_dimension(ncid,dimid,len=i)
        if (status.ne.nf90_noerr) then
          write(lp,'(2a)') 'nf90_inquire_dimension: x: ',
     .                     nf90_strerror(status)
          call xchalt('(rdcsss)')
                 stop '(rdcsss)'
        endif
        status=nf90_inq_dimid(ncid,'y',dimid)
        if (status.ne.nf90_noerr) then
          write(lp,'(2a)') 'nf90_inq_dimid: y: ',nf90_strerror(status)
          call xchalt('(rdcsss)')
                 stop '(rdcsss)'
        endif
        status=nf90_inquire_dimension(ncid,dimid,len=j)
        if (status.ne.nf90_noerr) then
          write(lp,'(2a)') 'nf90_inq_dimlen: y: ',nf90_strerror(status)
          call xchalt('(rdcsss)')
                 stop '(rdcsss)'
        endif
        if (i.ne.itdm.or.j.ne.jtdm) then
          write (lp,*) 'wrong dimensions in '//trim(filename)
          call xchalt('(rdcsss)')
                 stop '(rdcsss)'
        endif
c
        status=nf90_inq_varid(ncid,'sss',varid)
        if (status.ne.nf90_noerr) then
          write(lp,'(2a)') 'nf90_inq_varid: sss: ',nf90_strerror(status)
          call xchalt('(rdcsss)')
                 stop '(rdcsss)'
        endif
c
        start(1)=1
        start(2)=1
        count(1)=itdm
        count(2)=jtdm
        count(3)=1
c
      endif
c
      do k=1,12
        if (mnproc.eq.1) then
          start(3)=k
          status=nf90_get_var(ncid,varid,tmp2d,start,count)
          if (status.ne.nf90_noerr) then
            write(lp,'(2a)') 'nf90_get_var: sss: ',nf90_strerror(status)
            call xchalt('(rdcsss)')
                   stop '(rdcsss)'
          endif
        endif
        call xcaput(tmp2d,sssclm(1-nbdy,1-nbdy,k),1)
      enddo
c
      if (mnproc.eq.1) then
        status=nf90_close(ncid)
        if (status.ne.nf90_noerr) then
          write(lp,'(4a)') 'nf90_close: ',trim(filename),': ',
     .                     nf90_strerror(status)
          call xchalt('(rdcsss)')
                 stop '(rdcsss)'
        endif
      endif
c
      call xctilr(sssclm, 1,12, nbdy,nbdy, halo_ps)
c
      if (csdiag) then
        if (mnproc.eq.1) then
          write (lp,*) 'rdcsss:'
        endif
        call chksummsk(sssclm,ip,12,'sssclm')
      endif
c
      return
      end
