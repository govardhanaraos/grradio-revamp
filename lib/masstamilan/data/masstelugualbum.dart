class Album {
  final String albumName;
  final String albumArt;
  final String? starring;
  final String? music;
  final String? director;
  final String link;

  Album({
    required this.albumName,
    required this.albumArt,
    this.starring,
    this.music,
    this.director,
    required this.link,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      albumName: json['album_name'] as String,
      albumArt: json['album_art'] as String,
      starring: json['starring'] as String?,
      music: json['music'] as String?,
      director: json['director'] as String?,
      link: json['link'] as String,
    );
  }
}

class AlbumResponse {
  final List<Album> albums;
  final Pagination pagination;

  AlbumResponse({required this.albums, required this.pagination});

  factory AlbumResponse.fromJson(Map<String, dynamic> json) {
    return AlbumResponse(
      albums: (json['albums'] as List).map((e) => Album.fromJson(e)).toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class Pagination {
  final int? currentPage;
  final String? nextPage;
  final String? prevPage;
  final List<PageLink> pages;

  Pagination({
    this.currentPage,
    this.nextPage,
    this.prevPage,
    required this.pages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'],
      nextPage: json['next_page'],
      prevPage: json['prev_page'],
      pages: (json['pages'] as List).map((e) => PageLink.fromJson(e)).toList(),
    );
  }
}

class PageLink {
  final int? page;
  final String? url;

  PageLink({this.page, this.url});

  factory PageLink.fromJson(Map<String, dynamic> json) {
    return PageLink(page: json['page'], url: json['url']);
  }
}
