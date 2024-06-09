
import 'beaches_from_csv_method.dart';
import '../../models/beach.dart';

Future<List<Beach>> getBeachDataFromAssetFile() async {

  // List<dynamic> result = [];
  // context.read<LoadingProvider>().toggleAppLoadingState(true);
  // await getBeachData().then((List<dynamic> value) {
  //   result = value;
  //   context.read<LoadingProvider>().toggleAppLoadingState(false);
  // });

  // final ref = await FirebaseFirestore.instance.collection("beaches").get();
  // final List<Beach> beachesFromFirebase = ref.docs.map((doc) {
  //   return Beach(
  //       id: doc.id,
  //       name: doc.data()["name"],
  //       position: LatLng(doc.data()["lat"], doc.data()["lon"]),
  //       municipality: doc.data()["municipality"],
  //       isFavourite: getIsFavourite(favouriteBeaches, doc.data()["name"]));
  // }).toList();

  // context.read<BeachesProvider>().setBeaches = beachesFromFirebase
  //     .sortBeach(SortingOption(value: SortingValues.name));

  List<Beach> beachesFromCSV =
  await getBeachesFromCSV("assets/badevand_data.csv");

  return beachesFromCSV;
}