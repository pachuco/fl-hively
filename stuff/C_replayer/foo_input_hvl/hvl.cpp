#define MYVERSION "1.13"

/*
	changelog

2013-07-01 23:14 UTC - kode54
- Fixed noise generator
- Version is now 1.13

2013-05-12 21:12 UTC - kode54
- Fixed band-limited synthesis loop
- Version is now 1.12

2013-05-12 20:40 UTC - kode54
- Merged in some other changes from Hively Replayer version 1.8

2013-05-07 19:20 UTC - kode54
- Fixed 4xx effect importing from AHX v0 files
- Version is now 1.11

2013-05-07 00:06 UTC - kode54
- First attempt to fix mixing tone portamento with fine tone slide
- Version is now 1.10

2013-05-06 23:14 UTC - kode54
- Changed optimization settings

2012-02-19 19:51 UTC - kode54
- Added abort check to decoder
- Version is now 1.9

2011-11-01 23:59 UTC - kode54
- Implemented looping control
- Version is now 1.8

2011-08-18 19:59 UTC - kode54
- Implemented stereo separation control for AHX files
- Version is now 1.7

2011-01-11 05:21 UTC - kode54
- Implemented band-limited synthesis using blargg's blip_buf library
- Version is now 1.6

2010-04-13 14:55 UTC - kode54
- Amended preferences WM_INITDIALOG handler
- Version is now 1.5

2010-01-11 12:39 UTC - kode54
- Updated preferences page to 1.0 API
- Version is now 1.4

2009-12-12 15:02 UTC - kode54
- Updated Hively Tracker player to 1.6
- Version is now 1.3

2009-09-30 12:21 UTC - kode54
- Added division by zero protection for envelope setup code
- Version is now 1.2

2009-07-31 22:14 UTC - kode54
- Added null pointer and various buffer length checks to hvl_replay.c
- Version is now 1.1

*/

#define _WIN32_WINNT 0x0501

#include <foobar2000.h>
#include "../helpers/dropdown_helper.h"
#include "../ATLHelpers/ATLHelpers.h"

#include "hvl_replay.h"

#include "resource.h"

// {04663052-17A5-4638-BAE6-1AD0C3E1733F}
static const GUID guid_cfg_indefinite = 
{ 0x4663052, 0x17a5, 0x4638, { 0xba, 0xe6, 0x1a, 0xd0, 0xc3, 0xe1, 0x73, 0x3f } };
// {4BCFA055-4B91-4e3d-AD67-45A63EC15D87}
static const GUID guid_cfg_samplerate = 
{ 0x4bcfa055, 0x4b91, 0x4e3d, { 0xad, 0x67, 0x45, 0xa6, 0x3e, 0xc1, 0x5d, 0x87 } };
// {84F70B27-7FE6-4a4a-A256-8C65429D354C}
static const GUID guid_cfg_history_rate = 
{ 0x84f70b27, 0x7fe6, 0x4a4a, { 0xa2, 0x56, 0x8c, 0x65, 0x42, 0x9d, 0x35, 0x4c } };
// {AED6518A-6445-4A24-888F-85DAAD98C2C0}
static const GUID guid_cfg_ahx_stereo = 
{ 0xaed6518a, 0x6445, 0x4a24, { 0x88, 0x8f, 0x85, 0xda, 0xad, 0x98, 0xc2, 0xc0 } };

enum
{
	default_cfg_indefinite = 0,
	default_cfg_samplerate = 44100,
	default_cfg_ahx_stereo = 2
};

static cfg_int cfg_indefinite(guid_cfg_indefinite,default_cfg_indefinite);
static cfg_int cfg_samplerate(guid_cfg_samplerate,default_cfg_samplerate);
static cfg_int cfg_ahx_stereo(guid_cfg_ahx_stereo,default_cfg_ahx_stereo);

static class init_stuff
{
public:
	init_stuff()
	{
		hvl_InitReplayer();
	}

	~init_stuff() {}
} asdf;

class input_hvl
{
	struct hvl_tune * m_tune;

	t_filestats m_stats;

	unsigned srate;

	bool first_block, dont_loop;

	pfc::array_t< t_uint8 > file_buffer;

	pfc::array_t< t_int32 > sample_buffer;

public:
	input_hvl()
	{
		m_tune = 0;
	}

	~input_hvl()
	{
		hvl_FreeTune( m_tune );
	}

	void open( service_ptr_t<file> m_file, const char * p_path, t_input_open_reason p_reason, abort_callback & p_abort )
	{
		if ( m_file.is_empty() )
		{
			filesystem::g_open( m_file, p_path, ( p_reason == input_open_info_write ) ? filesystem::open_mode_write_existing : filesystem::open_mode_read, p_abort );
		}

		m_stats = m_file->get_stats( p_abort );

		t_uint8            * ptr;
		unsigned             size;

		srate = cfg_samplerate;

		t_filesize size64 = m_file->get_size_ex( p_abort );
		if ( size64 > ( 1 << 24 ) )
			throw exception_io_data();

		size = (unsigned) size64;

		file_buffer.set_size( size );
		ptr = file_buffer.get_ptr();

		m_file->read_object( ptr, size, p_abort );

		m_tune = hvl_LoadTune( ptr, size, srate, cfg_ahx_stereo );
		if ( ! m_tune )
			throw exception_io_data();
	}

	unsigned get_subsong_count()
	{
		return m_tune->ht_SubsongNr + 1;
	}

	t_uint32 get_subsong(unsigned p_index)
	{
		return p_index;
	}

	void get_info( t_uint32 p_subsong, file_info & p_info, abort_callback & p_abort )
	{
		struct hvl_tune * tune;
		tune = hvl_LoadTune( file_buffer.get_ptr(), file_buffer.get_size(), srate, 0 );
		if ( !tune )
			throw exception_io_data();

		p_info.info_set( "encoding", "synthesized" );
		p_info.info_set_int( "channels", 2 );
		p_info.meta_set( "title", pfc::stringcvt::string_utf8_from_ansi( tune->ht_Name, 128 ) );
		pfc::string8 temp;
		for ( unsigned i = 1, j = tune->ht_InstrumentNr; i <= j; ++i )
		{
			temp = "inst";
			temp += pfc::format_int( i, 2 );
			p_info.meta_set( temp, pfc::stringcvt::string_utf8_from_ansi( tune->ht_Instruments[ i ].ins_Name, 128 ) );
		}

		unsigned safety = 2 * 60 * 60 * 50 * tune->ht_SpeedMultiplier; // 2 hours, just like foo_dumb

		hvl_InitSubsong( tune, p_subsong );

		while ( ! tune->ht_SongEndReached && safety )
		{
			hvl_play_irq( tune );
			--safety;
		}

		p_info.set_length( (double) tune->ht_PlayingTime / (double) tune->ht_SpeedMultiplier / 50. );

		hvl_FreeTune( tune );
	}

	t_filestats get_file_stats( abort_callback & p_abort )
	{
		return m_stats;
	}

	void decode_initialize( t_uint32 p_subsong, unsigned p_flags, abort_callback & p_abort )
	{
		first_block = true;

		hvl_InitSubsong( m_tune, p_subsong );

		sample_buffer.set_size( srate / 50 * 2 );

		dont_loop = !! ( p_flags & input_flag_no_looping ) || !cfg_indefinite;
	}

	bool decode_run(audio_chunk & p_chunk,abort_callback & p_abort)
	{
		p_abort.check();

		if ( dont_loop && m_tune->ht_SongEndReached ) return false;

		int const sample_count = srate / 50;

		t_int8 * ptr = ( t_int8 * ) sample_buffer.get_ptr();

		hvl_DecodeFrame( m_tune, ptr, ptr + 4, 8 );

		p_chunk.set_data_size( sample_count * 2 );

		audio_math::convert_from_int32( (t_int32 *)ptr, sample_count * 2, p_chunk.get_data(), 1 << 8 );
		
		p_chunk.set_srate( srate );
		p_chunk.set_channels( 2, audio_chunk::channel_config_stereo );
		p_chunk.set_sample_count( sample_count );
		
		return true;
	}

	void decode_seek( double p_seconds, abort_callback & p_abort )
	{
		first_block = true;

		unsigned frame = unsigned ( audio_math::time_to_samples( p_seconds, 50 * m_tune->ht_SpeedMultiplier ) );
		if ( m_tune->ht_PlayingTime > frame )
			hvl_InitSubsong( m_tune, m_tune->ht_SongNum );

		while ( m_tune->ht_PlayingTime < frame )
			hvl_play_irq( m_tune );
	}

	bool decode_can_seek()
	{
		return true;
	}

	bool decode_get_dynamic_info(file_info & p_out, double & p_timestamp_delta)
	{
		if ( first_block )
		{
			p_out.info_set_int( "samplerate", srate );
			first_block = false;
			return true;
		}
		return false;
	}

	bool decode_get_dynamic_info_track( file_info & p_out, double & p_timestamp_delta )
	{
		return false;
	}

	void decode_on_idle( abort_callback & p_abort )
	{
	}

	void retag_set_info( t_uint32 p_subsong, const file_info & p_info, abort_callback & p_abort )
	{
	}

	void retag_commit( abort_callback & p_abort )
	{
	}

	static bool g_is_our_content_type( const char * p_content_type )
	{
		return false;
	}

	static bool g_is_our_path( const char * p_path, const char * p_extension )
	{
		return !stricmp(p_extension, "HVL") || !stricmp(p_extension, "AHX");
	}
};

static cfg_dropdown_history cfg_history_rate(guid_cfg_history_rate,16);

static const int srate_tab[]={8000,11025,16000,22050,24000,32000,44100,48000,64000,88200,96000};

class CMyPreferences : public CDialogImpl<CMyPreferences>, public preferences_page_instance {
public:
	//Constructor - invoked by preferences_page_impl helpers - don't do Create() in here, preferences_page_impl does this for us
	CMyPreferences(preferences_page_callback::ptr callback) : m_callback(callback) {}

	//Note that we don't bother doing anything regarding destruction of our class.
	//The host ensures that our dialog is destroyed first, then the last reference to our preferences_page_instance object is released, causing our object to be deleted.


	//dialog resource ID
	enum {IDD = IDD_CONFIG};
	// preferences_page_instance methods (not all of them - get_wnd() is supplied by preferences_page_impl helpers)
	t_uint32 get_state();
	void apply();
	void reset();

	//WTL message map
	BEGIN_MSG_MAP(CMyPreferences)
		MSG_WM_INITDIALOG(OnInitDialog)
		COMMAND_HANDLER_EX(IDC_INDEFINITE, BN_CLICKED, OnClicked)
		COMMAND_HANDLER_EX(IDC_SAMPLERATE, CBN_EDITCHANGE, OnEditChange)
		COMMAND_HANDLER_EX(IDC_SAMPLERATE, CBN_SELCHANGE, OnSelectionChange)
		DROPDOWN_HISTORY_HANDLER(IDC_SAMPLERATE, cfg_history_rate)
		MSG_WM_HSCROLL(OnHScroll)
	END_MSG_MAP()
private:
	BOOL OnInitDialog(CWindow, LPARAM);
	void OnClicked(UINT, int, CWindow);
	void OnEditChange(UINT, int, CWindow);
	void OnSelectionChange(UINT, int, CWindow);
	void OnHScroll(UINT, UINT, CScrollBar);
	bool HasChanged();
	void OnChanged();

	const preferences_page_callback::ptr m_callback;
};

BOOL CMyPreferences::OnInitDialog(CWindow, LPARAM) {
	CWindow w;
	char temp[16];
	int n;
	for(n=tabsize(srate_tab);n--;)
	{
		if (srate_tab[n] != cfg_samplerate)
		{
			itoa(srate_tab[n], temp, 10);
			cfg_history_rate.add_item(temp);
		}
	}
	itoa(cfg_samplerate, temp, 10);
	cfg_history_rate.add_item(temp);
	w = GetDlgItem( IDC_SAMPLERATE );
	cfg_history_rate.setup_dropdown( w );
	::SendMessage( w, CB_SETCURSEL, 0, 0 );

	w = GetDlgItem( IDC_AHX_STEREO );
	w.SendMessage( TBM_SETRANGE, 0, MAKELONG( 0, 4 ) );
	w.SendMessage( TBM_SETPOS, 1, cfg_ahx_stereo );

	SendDlgItemMessage( IDC_INDEFINITE, BM_SETCHECK, cfg_indefinite, FALSE );
	
	return FALSE;
}

void CMyPreferences::OnClicked(UINT, int, CWindow) {
	OnChanged();
}

void CMyPreferences::OnEditChange(UINT, int, CWindow) {
	OnChanged();
}

void CMyPreferences::OnSelectionChange(UINT, int, CWindow) {
	OnChanged();
}

void CMyPreferences::OnHScroll(UINT, UINT, CScrollBar) {
	OnChanged();
}

t_uint32 CMyPreferences::get_state() {
	t_uint32 state = preferences_state::resettable;
	if (HasChanged()) state |= preferences_state::changed;
	return state;
}

void CMyPreferences::reset() {
	SendDlgItemMessage( IDC_INDEFINITE, BM_SETCHECK, default_cfg_indefinite, FALSE );
	SetDlgItemInt( IDC_SAMPLERATE, default_cfg_samplerate );
	SendDlgItemMessage( IDC_AHX_STEREO, TBM_SETPOS, 1, default_cfg_ahx_stereo );
	
	OnChanged();
}

void CMyPreferences::apply() {
	char temp[16];
	int t = GetDlgItemInt( IDC_SAMPLERATE, NULL, FALSE );
	if ( t < 6000 ) t = 6000;
	else if ( t > 192000 ) t = 192000;
	SetDlgItemInt( IDC_SAMPLERATE, t, FALSE );
	itoa( t, temp, 10 );
	cfg_history_rate.add_item( temp );
	cfg_samplerate = t;
	cfg_ahx_stereo = SendDlgItemMessage( IDC_AHX_STEREO, TBM_GETPOS );
	cfg_indefinite = SendDlgItemMessage( IDC_INDEFINITE, BM_GETCHECK );
	
	OnChanged(); //our dialog content has not changed but the flags have - our currently shown values now match the settings so the apply button can be disabled
}

bool CMyPreferences::HasChanged() {
	return SendDlgItemMessage( IDC_INDEFINITE, BM_GETCHECK ) != cfg_indefinite ||
		GetDlgItemInt( IDC_SAMPLERATE, NULL, FALSE ) != cfg_samplerate ||
		SendDlgItemMessage( IDC_AHX_STEREO, TBM_GETPOS ) != cfg_ahx_stereo;
}
void CMyPreferences::OnChanged() {
	//tell the host that our state has changed to enable/disable the apply button appropriately.
	m_callback->on_state_changed();
}

class preferences_page_myimpl : public preferences_page_impl<CMyPreferences> {
	// preferences_page_impl<> helper deals with instantiation of our dialog; inherits from preferences_page_v3.
public:
	const char * get_name() {return "Hively Tracker decoder";}
	GUID get_guid() {
		// {94F07062-C0FC-455e-A6BE-0F008F980231}
		static const GUID guid = { 0x94f07062, 0xc0fc, 0x455e, { 0xa6, 0xbe, 0xf, 0x0, 0x8f, 0x98, 0x2, 0x31 } };
		return guid;
	}
	GUID get_parent_guid() {return guid_input;}
};

class hvl_file_types : public input_file_type
{
	virtual unsigned get_count()
	{
		return 2;
	}

	virtual bool get_name(unsigned idx, pfc::string_base & out)
	{
		static const char * names[] = { "Abyss AHX files", "Hively Tracker files" };
		if (idx > 1) return false;
		out = names[ idx ];
		return true;
	}

	virtual bool get_mask(unsigned idx, pfc::string_base & out)
	{
		static const char * extensions[] = { "AHX", "HVL" };
		out = "*.";
		if (idx > 1) return false;
		out += extensions[ idx ];
		return true;
	}

	virtual bool is_associatable(unsigned idx)
	{
		return true;
	}
};

static input_factory_t           <input_hvl>               g_input_hvl_factory;
static preferences_page_factory_t<preferences_page_myimpl> g_config_mod_factory;
static service_factory_single_t  <hvl_file_types>          g_input_file_type_hvl_factory;

DECLARE_COMPONENT_VERSION( "Hively Tracker decoder", MYVERSION, "Using Hively Tracker player v1.6.");

VALIDATE_COMPONENT_FILENAME( "foo_input_hvl.dll" );
